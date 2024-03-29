bash-4.4 ~ $ cat oc-pod_tcpdump
#!/usr/bin/env bash

set -eo pipefail

tcpdump_opts="-s0 -U -w -"
quiet="false"

exit_err() {
   echo >&2 "${1}"
   exit 1
}

usage() {
    local SELF
    SELF="pod-tcpdump"
    if [[ "$(basename "$0")" == oc-* ]]; then
        SELF="oc pod-tcpdump"
    fi
    cat <<EOF
pod-tcpdump is a debugging tool helping to start a tcpdump on a running pod.
The command starts a debug pod on the node where the pod is scheduled and
then executes tcpdump with nsenter(1) into the pod namespace.

Usage:
    $SELF POD [OPTIONS]

Options:
    -q | --quiet : run $SELF in quiet mode, without printing any message,
                   useful with -f - and to pipe the output directly to wireshark

    -n | --namespace NS : define the namespace where the POD is residing,
                          if not defined uses the current namespace

    -f | --filename FILE : the filename where the output of tcpdump should be
                           saved, using -f - will print on stdout

    -- | ++ TCPDUMP-OPTIONS : a separator between the $SELF options and the
                              tcpdump options. Using ++ the TCPDUMP-OPTIONS
                              are appended to the defaults ($tcpdump_opts).
                              Using -- the default options are removed

Remember that passing the '-w file.pcap' option will not work: tcpdump is
executed in a container, file.pcap will be not available on the local machine.

Example:
    Start a tcpdump on the pod nginx-1-7xm8j in the current namespace:
    $ $SELF nginx-1-7xm8j

    Start a tcpdump on the pod and save the output on a specific file
    (by default the filename is auto-generated)
    $ $SELF -f dump.pcap nginx-1-7xm8j

    Start a tcpdump on the pod and print the output on standard output
    $ $SELF -f - nginx-1-7xm8j

    Start a tcpdump on the pod router-c876w in the openshift-ingress pod:
    $ $SELF -n openshift-ingress router-c876w

    List all the available network interfaces on a pod (with tcpdump -D)
    $ $SELF router-c876w -f - -- -D

    Start a tcpdump on the pod router-c876w with custom options:
    $ $SELF router-c876w -f dump.pcap -- -i tun0 -s0 -U -w -

    Append some tcpdump options to the default options
    $ $SELF router-c876w -f dump.pcap ++ -i any port 80

    Start the tcpdump in quiet mode and pipe to tshark
    $ $SELF ruby-ex-1-wbn4l -f - -q | tshark -r - http
EOF
}

is_running() {
    phase=$(oc get pod -n "$namespace" "$pod" -o jsonpath='{.status.phase}')
    if [[ "$phase" != "Running" ]]; then
        echo "Pod is not in Running phase ($phase)"
        exit -1
    fi
}

get_node() {
    oc get pod -n "$namespace" "$pod" -o jsonpath='{.spec.nodeName}'
}

main() {
    [ $# -eq 0 ] && exit_err "You must specify a pod for dumping network traffic"

    while [ $# -gt 0 ]; do
        case "$1" in
            -h | --help)
                usage
                exit
                ;;
            -n | --namespace)
                namespace="$2"
                shift
                shift
                ;;
            -f | --filename)
                filename="$2"
                shift
                shift
                ;;
            -q | --quiet)
                quiet="true"
                shift
                ;;
            --)
                shift
                tcpdump_opts="$@"
                break
                ;;
            ++)
                shift
                tcpdump_opts="$tcpdump_opts $@"
                break
                ;;
            *)
                pod="$1"
                shift
                ;;
        esac
    done
    
    if [[ "$namespace" == "" ]]; then
        namespace=$(oc config view --minify --output 'jsonpath={..namespace}')
    fi
    is_running $pod
    node=$(get_node)
    if [[ "$filename" == "" ]]; then
        filename="${node}_${namespace}_${pod}_$(date +\%d_%m_%Y-%H_%M_%S-%Z).pcap"
    fi
    if [[ "$filename" == "-" ]]; then
        exec 4>&1
        filename="stdout"
    else
        exec 4>$filename
    fi

    if [[ "$quiet" == "false" ]]; then
        echo "Dumping traffic on pod $pod in $namespace, pod is running on node $node"
        echo "Data gathered via 'tcpdump $tcpdump_opts' will be saved on $filename"
    else
        exec 2>/dev/null
    fi
    cat <<EOF | oc debug node/$node >&4
cid=\$(chroot /host crictl ps -q --pod \$(chroot /host crictl pods -q --name $pod --namespace $namespace) | head -n 1)
pid=\$(chroot /host crictl inspect --output yaml \$cid | grep 'pid:' | awk '{print \$2}')
nsenter -n -t \$pid -- tcpdump $tcpdump_opts
EOF
}
