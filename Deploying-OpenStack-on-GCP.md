### Deploying OpenStack on GCP ####

The guide is split up in the following sections:

Creating the GCE VM with nested KVM enabled
Deploying OpenStack using OpenStack Ansible with all in one(aio) node mode
Accessing the environment
1. Creating the GCE VMs with nested KVM enbaled
Let's create a VM called openstack-1 with 16 vCPUs. This VM will be used to run additional VMs that are spawned by OpenStack. The GCE VM itself will run the OpenStack control plane and serve as an OpenStack compute node. Run the following commands:
```
gcloud compute disks create ubuntu2004disk \
  --image-project ubuntu-os-cloud --image-family ubuntu-2004-lts \
  --zone us-central1-a
```
```
gcloud compute images create ubuntu-2004-nested \
  --source-disk ubuntu2004disk --source-disk-zone us-central1-a \
  --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
```
```
gcloud compute instances create openstack-1 --zone us-central1-a \
              --image ubuntu-2004-nested \
              --boot-disk-size 300G \
              --boot-disk-type pd-ssd \
              --can-ip-forward \
              --network default \
              --tags http-server,https-server,novnc,openstack-apis \
              --min-cpu-platform "Intel Haswell" \
              --machine-type n1-standard-16
              
```              
Now verify that nested KVM is enabled:
```
gcloud compute ssh openstack-1 --zone us-central1-a
sudo -i
apt-get update && apt-get install qemu-kvm -y
```
kvm-ok

The output of kvm-ok should show the following:

kvm-ok
# Output should look like below
INFO: /dev/kvm exists
KVM acceleration can be used

2. Deploying OpenStack
Now let's deploy OpenStack using OpenStack Ansible with all in one(aio) mode. Ensure you're still SSHed into the openstack-1 VM, if not run:
```
gcloud compute ssh openstack-1 --zone us-central1-a
sudo -i

```
Start a screen or tmux session because deploying OpenStack can take 30 min to 2 hours. Run the following command:
```
screen
```

Clone openstack-ansible repo to openstack-1:
```
git clone https://opendev.org/openstack/openstack-ansible \
    /opt/openstack-ansible
cd /opt/openstack-ansible
git checkout stable/ussuri

```
Install Ansible on the VM and install all the required Ansible roles:
```
scripts/bootstrap-ansible.sh

```
Bootstrap the AIO configuration for openstack ansible

```
export SCENARIO='aio_lxc_barbican_octavia'
scripts/bootstrap-aio.sh
```

Create the LXC containers that run the different OpenStack components and install OpenStack:

```
openstack-ansible playbooks/setup-hosts.yml \
    playbooks/setup-infrastructure.yml \
    playbooks/setup-openstack.yml
    
```
Now OpenStack should have been succesfully deployed on the openstack-1 VM.

3. Accessing the environment

The environment is currently only exposed on the internal IP address. The floating IP range is also only routable within the openstack-1 VM. So let's setup a tunnel to the openstack-1 VM to be able to access the newly deployed environment. One way to create a tunnel is to use sshuttle.

On your local machine (laptop, desktop etc), run the following commands to setup the tunnel with sshuttle:
```
PUBLIC_IP=$(gcloud compute instances describe openstack-1 --zone us-central1-a \
         --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
         
```
# note that you may need to add your public SSH key in GCP

```
sshuttle -r sam@$PUBLIC_IP 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16

```
Now you should be able to access the web UI on the private VPC IP address of your VM. Get the private address of your openstack-1 VM with the following command:

```
gcloud compute instances describe openstack-1 --zone us-central1-a \
         --format='get(networkInterfaces[0].networkIP)'
```
In your browser go to https://$PRIVATE_IP and you should be able to see the Horizon UI.
