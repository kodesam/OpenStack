###  Single-node OpenStack deployment on Ubuntu ###
Use devmode and the beta channel:

```sudo snap install microstack --devmode --beta```

microstack (beta) ussuri from Canonical✓ installed

Information on the installed snap can be viewed like this:

```snap list microstack ```

Name        Version  Rev  Tracking     Publisher   Notes
microstack  ussuri   242  latest/beta  canonical✓  devmode

### Initialisation ###
The initialisation step automatically deploys, configures, and starts OpenStack services. 
In particular, it will create the database, networks, an image, several flavors, and ICMP/SSH security groups. 


```sudo microstack init --auto --control```
```
2021-12-01 06:58:12,339 - microstack_init - INFO - Configuring clustering ...
2021-12-01 06:58:12,705 - microstack_init - INFO - Setting up as a control node.
2021-12-01 06:58:16,864 - microstack_init - INFO - Generating TLS Certificate and Key
2021-12-01 06:58:18,303 - microstack_init - INFO - Configuring networking ...
2021-12-01 06:58:26,263 - microstack_init - INFO - Opening horizon dashboard up to *
2021-12-01 06:58:27,571 - microstack_init - INFO - Waiting for RabbitMQ to start ...
Waiting for 192.168.64.13:5672
2021-12-01 06:58:35,089 - microstack_init - INFO - RabbitMQ started!
2021-12-01 06:58:35,090 - microstack_init - INFO - Configuring RabbitMQ ...
2021-12-01 06:58:36,660 - microstack_init - INFO - RabbitMQ Configured!
2021-12-01 06:58:36,685 - microstack_init - INFO - Waiting for MySQL server to start ...
Waiting for 192.168.64.13:3306
2021-12-01 06:58:47,217 - microstack_init - INFO - Mysql server started! Creating databases ...
2021-12-01 06:58:49,435 - microstack_init - INFO - Configuring Keystone Fernet Keys ...
2021-12-01 06:59:10,711 - microstack_init - INFO - Bootstrapping Keystone ...
2021-12-01 06:59:26,601 - microstack_init - INFO - Creating service project ...
2021-12-01 06:59:34,281 - microstack_init - INFO - Keystone configured!
2021-12-01 06:59:34,311 - microstack_init - INFO - Configuring the Placement service...
2021-12-01 07:00:01,833 - microstack_init - INFO - Running Placement DB migrations...
2021-12-01 07:00:09,660 - microstack_init - INFO - Configuring nova control plane services ...
2021-12-01 07:00:28,461 - microstack_init - INFO - Running Nova API DB migrations (this may take a lot of time)...
2021-12-01 07:01:00,824 - microstack_init - INFO - Running Nova DB migrations (this may take a lot of time)...
Waiting for 192.168.64.13:8774
2021-12-01 07:02:21,609 - microstack_init - INFO - Creating default flavors...
2021-12-01 07:03:01,699 - microstack_init - INFO - Configuring nova compute hypervisor ...
2021-12-01 07:03:01,700 - microstack_init - INFO - Checking virtualization extensions presence on the host
2021-12-01 07:03:01,748 - microstack_init - WARNING - Unable to determine hardware virtualization support by CPU vendor id "GenuineIntel": assuming it is not supported.
2021-12-01 07:03:01,748 - microstack_init - WARNING - Hardware virtualization is not supported - software emulation will be used for Nova instances
2021-12-01 07:03:04,899 - microstack_init - INFO - Configuring the Spice HTML5 console service...
2021-12-01 07:03:05,507 - microstack_init - INFO - Configuring Neutron
Waiting for 192.168.64.13:9696
2021-12-01 07:05:12,955 - microstack_init - INFO - Configuring Glance ...
Waiting for 192.168.64.13:9292
2021-12-01 07:06:02,637 - microstack_init - INFO - Adding cirros image ...
2021-12-01 07:06:06,782 - microstack_init - INFO - Creating security group rules ...
2021-12-01 07:06:20,427 - microstack_init - INFO - Configuring the Cinder services...
2021-12-01 07:07:43,245 - microstack_init - INFO - Running Cinder DB migrations...
2021-12-01 07:07:59,382 - microstack_init - INFO - restarting libvirt and virtlogd ...
2021-12-01 07:08:19,291 - microstack_init - INFO - Complete. Marked microstack as initialized!
```
### Query OpenStack

The standard openstack client comes pre-installed and is invoked like so:

```microstack.openstack <command> ```

To list the default image:

```microstack.openstack image list```
```
+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 26bad841-6606-40c5-8a01-decfe57252da | cirros | active |

```
To get the default list of flavors:

```microstack.openstack flavor list```

```
+----+-----------+-------+------+-----------+-------+-----------+
| ID | Name      |   RAM | Disk | Ephemeral | VCPUs | Is Public |
+----+-----------+-------+------+-----------+-------+-----------+
| 1  | m1.tiny   |   512 |    1 |         0 |     1 | True      |
| 2  | m1.small  |  2048 |   20 |         0 |     1 | True      |
| 3  | m1.medium |  4096 |   20 |         0 |     2 | True      |
| 4  | m1.large  |  8192 |   20 |         0 |     4 | True      |
| 5  | m1.xlarge | 16384 |   20 |         0 |     8 | True      |
+----+-----------+-------+------+-----------+-------+-----------+
```



