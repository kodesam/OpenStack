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

### Query OpenStack

The standard openstack client comes pre-installed and is invoked like so:

```microstack.openstack <command> ```

To list the default image:

```microstack.openstack image list```

To get the default list of flavors:

```microstack.openstack flavor list```
