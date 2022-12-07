# OCNE - Oracle Cloud Native Environment Ansible Playbooks

The Oracle Cloud Native Environment playbooks support servers on Oracle Linux 8 with the latest version of Oracle Cloud Native Environment (OCNE). The playbooks only supports the quick install procedure with an configuration file.

These are the playbooks to run in Ansible:

* deploy-ocne.yml - deploys initial OCNE environment including the Kubernetes and Helm modules
* deploy-mod-metallb.yml - Deploys MetalLB loadbalancer
* deploy-mod-ociccm.yml - Deploys the OCI-CCM module when running in Oracle OCI used for OCI loadbalancer and storage
* deploy-mod-istio.yml - deploys Istio service mesh
* deploy-mod-olm.yml - deploys OCNE lifecycle manager for Operators
* reset-ocne.yml - removes an OCNE environment including additional modules


# Configuration

Make sure the following configuration steps are done before running the playbooks.

## OCNE Configuration file

The playbooks use the [Quick Install using Configuration File](https://docs.oracle.com/en/operating-systems/olcne/1.5/quickinstall/task-provision-config.html) installation scenario.
The configuration file includes all information about the environments and modules you want to create. 
This file in combination with the quick install procedure of OCNE saves repeated steps in the 
installation process. 

The OCNE playbooks expect to have a configuration file in the `<playbookdir>/files` directory with file extension `.yaml`. You can name the file whatever you want as long as the file-name is added to the playbook variables (eg: `env_file: ocne-environment.yaml`) for you intended OCNE cluster.

Information on how to create a configuration file is explained in the [OCNE Platform CLI documentation](https://docs.oracle.com/en/operating-systems/olcne/1.5/olcnectl/config.html#write).

## Inventory file
The Inventory file defines the hostnames and roles in the OCNE cluster. Example inventory files are provided in the `<playbookdir>/inventories` directory. The `hosts-example.ini` file provides configuration information to deploy the initial OCNE cluster. 

Add the hostnames of your OCNE cluster to the following groups in the inventory file:
| Variable | Required | Description |
| -------- | -------- | ----------- |
| ocne_op | Yes | the OCNE Operator Node
| ocne_kube_control | Yes | the Kubernetes Control Plane Nodes
| ocne_kube_worker | Yes | the Kubernetes Worker Nodes


## Variables
The variables for the OCNE cluster are defined in the `<playbookdir>/group_vars/all.yml` file. Example variable files are provided for an initial cluster. Below is a list of the used variables. All the variables must exist in the file, some are required others can be left empty when not in use.

| Variable | Required | Description |
| -------- | -------- | ----------- |
| use_proxy | Yes | Set use_proxy to _true_ if the environment is behind a proxy, else set to _false_
| my_https_proxy | | Proxy details, leave empty if not using proxy
| my_http_proxy | | Proxy details, leave empty if not using proxy
| my_no_proxy | | Proxy details, leave empty if not using proxy
| do_preparation | Yes | Set do_preparation to _true_ for the first deployment, it configures SSH keys, certificates and repositories. After a reset_ocne playbook run it should be set to _false_ to skip the basic plumbing
| container_registry | Yes | Container registry path to get the OCNE component container images
| virtual_ip | | The virtual IP address for an olcne-nginx with internal load balancer
| ocne_environment | Yes | Set name for the OCNE environment
| ocne_k8s | Yes | Set name of the OCNE Kubernetes module
| ocne_helm | Yes | Set name of the OCNE Helm module, installed by default but only used when other modules are configured 
| ocne_istio | | Set name of the OCNE Istio module. Leave empty if not creating Istio module
| ocne_olm | | Set name of the OCNE OLM module. Leave empty if not creating OLM module
| ocne_oci | | Set name of the OCNE OCI-CCM module. Leave empty if not creating CCM module
| ocne_metallb | | Set name of the OCNE MetalLB module. Leave empty if not creating CCM module

## MetalLB Load balancer module (optional)
You must provide a MetalLB configuration file in the playbooks files subdirectory, the file will be copied to the on the operator node and used with the MetalLB module configuration. An example configuration file is provided, adjust to your own IP address range settings.

    $ cd <playbookdir>/files
    $ ls -l
    -rw-rw-r-- 1 opc opc   98 Aug 12 12:23 metallb-config.yaml
    $ cat metallb-config.yaml
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.178.90-192.168.178.95

## Oracle Cloud OCI-CCM module (optional)

The playbook to deploy the [OCI Cloud Controller Manager (CCM)](https://github.com/oracle/oci-cloud-controller-manager) module includes your OCI cloud authentication and configuration settings. When you have added your authentication and OCI configuration information in the playbook, it is recommended to encrypt the file with an ansible vault password. The password wil be asked when you run the playbook in the CLI or in Oracle Linux Automation Manager. To encrypt the playbook:

    $ cp deploy-mod-ociccm-example.yml deploy-mod-ociccm.yml
    $ <edit your settings in var-section>
    $ ansible-vault encrypt deploy-mod-ociccm.yml

The following variables are required in the `deploy-mod-ociccm.yml` playbook, consult the [OCNE documentation](https://docs.oracle.com/en/operating-systems/olcne/) (Storage or Application Loadbalancers) for additional information.

| Variable | Required | Description |
| -------- | -------- | ----------- |
| oci_region | Yes | Example: uk-london-1
| oci_tenancy | Yes | Example: ocid1.tenancy.oc1..aaaaaaae..........cok7mlsa
| oci_compartment | Yes | Example: ocid1.compartment.oc1..aaaaaaaa..........bmn3j6qh
| oci_user | Yes | Example: ocid1.user.oc1..aaaaaaaa..........wp432ssg
| oci_fingerprint | Yes | Example: 4e:69:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:cc
| oci_private_key | Yes | Example: /tmp/oci_api_key.pem
| oci_vcn | Yes | Example: ocid1.vcn.oc1.uk-london-1.amaaaaaa..........j5jw3iag
| lb_subnet1 | Yes | Example: ocid1.subnet.oc1.uk-london-1.aaaaaaaa..........w3a75jhf

### OCI API Key 
For the OCI-CCM module you need to store the API key file in the playbooks files subdirectory:

    $ cd <playbookdir>/files
    $ ls -l
    total 16
    -rw------- 1 opc opc 1730 Aug 12 13:07 oci_api_key.pem

# How to use

The playbooks are tested with kubernetes nodes for on-premise infrastructure as well as OCI instances in Oracle cloud. They both work from the command line by running the `ansible-playbook` command or when they are imported in Oracle Linux Automation Manager (OLAM). Example command line:

    $ ansible-playbook -i inventories/hosts.ini ./deploy-ocne.yml
    $ ansible-playbook -i inventories/hosts.ini ./deploy-mod-ociccm.yml

If you stored the playbooks as project in Oracle Linux Automation Manager (OLAM) then best thing to do is to create an inventory in the OLAM UI, add hosts and groups as described above and add the required variables to the Variables section in the inventory.
