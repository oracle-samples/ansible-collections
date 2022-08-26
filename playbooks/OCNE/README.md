# OCNE - Oracle Cloud Native Environment Ansible Playbooks

The Oracle Cloud Native Environment playbooks are simplified versions of the [OCNE Deployment Tool](https://github.com/oracle/ocne-deploy-tool). The playbooks support servers on Oracle Linux 8 with the latest version of Oracle Cloud Native Environment (OCNE).

These are the playbooks to run in Ansible:

* deploy-ocne.yml - deploys initial OCNE environment including the Kubernetes and Helm modules
* deploy-mod-metallb.yml - Deploys MetalLB loadbalancer
* deploy-mod-ociccm.yml - Deploys the OCI-CCM module when running in Oracle OCI used for OCI loadbalancer and storage
* deploy-mod-istio.yml - deploys Istio service mesh
* deploy-mod-olm.yml - deploys OCNE lifecycle manager for Operators
* upscale-ocne.yml - add control plane or worker nodes to existing cluster
* downscale-ocne.yml - scales cluster back to initial amount of servers
* undeploy-ocne.yml - removes an OCNE environment including additional modules
* uninstall-ocne.yml - removes all OCNE packages from the servers

The playbooks are tested with OCNE 1.5 and run with the ansible CLI and Oracle Linux Automation Manager.


# Configuration

Make sure the following configuration steps are done before running the playbooks.

## SSH keys
You need to generate ssh-keys for self-signed certificate distribution over the kubernetes nodes during the installation process. Store the keys in the playbooks directory, for example:

    $ cd <playbookdir>/files
    $ ssh-keygen -t rsa -f id_rsa -N '' -q
    $ ls -l
    -rw------- 1 opc opc 2610 Aug  8 11:22 id_rsa
    -rw-r--r-- 1 opc opc  574 Aug  8 11:22 id_rsa.pub


## Inventory file
The Inventory file defines the hostnames and roles in the OCNE cluster. Example inventory files are provided in the `<playbookdir>/inventories` directory. The `hosts-example.ini` file provides configuration information to deploy the initial OCNE cluster, the `hosts-upscale-example.ini` file provides configuration information to upscale the cluster with additional control plane or worker nodes.

Add the hostnames of your OCNE cluster to the following groups in the inventory file:
| Variable | Required | Description |
| -------- | -------- | ----------- |
| ocne_op | Yes | the OCNE Operator Node
| ocne_kube_control | Yes | the Kubernetes Control Plane Nodes
| ocne_kube_worker | Yes | the Kubernetes Worker Nodes
| ocne_new_kube_control | | leave empty for initial cluster, but add control plane hostnames when you want to upscale the cluster
| ocne_new_kube_worker | | leave empty for initial cluster, but add worker hostnames when you want to upscale the cluster


## Variables
The variables for the OCNE cluster are defined in the `<playbookdir>/group_vars/all.yml` file. Example variable files are provided for an initial cluster and extended cluster. Below is a list of the used variables. All the variables must exist in the file, some are required others can be left empty when not in use.

| Variable | Required | Description |
| -------- | -------- | ----------- |
| use_proxy | Yes | Set use_proxy to _true_ if the environment is behind a proxy, else set to _false_
| my_https_proxy | | Proxy details, leave empty if not using proxy
| my_http_proxy | | Proxy details, leave empty if not using proxy
| my_no_proxy | | Proxy details, leave empty if not using proxy
| container_registry | Yes | Container registry path to get the OCNE component container images
| ha | Yes | Set to _true_ to deploy high availability control planes, _false_ for a single control plane. Consider to use _true_ to easily scale to multi-master control planes in a later phase
| virtual_ip | | The virtual IP address for an olcne-nginx with internal load balancer, required when _ha_ is _true_
| restricted_ips | Yes | set to _true_ to set up certificates for the restricted external IPs Webhook
| ocne_repo | Yes | Set the OCNE dnf repository of the version to install (ol8_olcne15)
| ocne_environment | Yes | Set name for the OCNE environment
| ocne_k8s | Yes | Set name of the OCNE Kubernetes module
| ocne_helm | Yes | Set name of the OCNE Helm module, installed by default but only used when other modules are configured 
| ocne_istio | | Set name of the OCNE Istio module. Leave empty if not creating Istio module
| ocne_olm | | Set name of the OCNE OLM module. Leave empty if not creating OLM module
| ocne_oci | | Set name of the OCNE OCI-CCM module. Leave empty if not creating CCM module
| ocne_metallb | | Set name of the OCNE MetalLB module. Leave empty if not creating CCM module
| control_nodes | Yes | List of control plane nodes, should be \<fqdn\>:8090
| worker_nodes | Yes | List of control plane nodes, should be \<fqdn\>:8090
| all_nodes | Yes | List of all kubernetes nodes in the cluster, should be \<fqdn\>
| add_control_nodes | | List of control plane nodes to add to existing cluster, should be \<fqdn\>:8090
| add_worker_nodes | | List of worker nodes to add to existing cluster, should be \<fqdn\>:8090
| add_nodes | | List of all nodes added to existing cluster, should be \<fqdn\>


## Optional: MetalLB Loadbalancer
You must provide a MetalLB configuration file in the playbooks files subdirectory, the file will be copied to the operator node and used with the MetalLB module configuration. An example configuration file is provided, adjust to your own IP address range settings.

    $ cd <playbookdir>/files
    $ ls -l
    -rw-rw-r-- 1 opc opc   98 Aug 12 12:23 metallb-config.yaml
    $ cat metallb-config.yaml
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.178.90-192.168.178.95

## Optional: Oracle Cloud OCI Loadbalancer and Storage

### OCI API Key
For the OCI-CCM module you need to store the API key file in the playbooks files subdirectory:

    $ cd <playbookdir>/files
    $ ls -l
    total 16
    -rw------- 1 opc opc 1730 Aug 12 13:07 oci_api_key.pem

### OCI-CCM variables

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

# How to use

The playbooks are tested with kubernetes nodes for on-premise infrastructure as well as OCI instances in Oracle cloud. They both work from the command line by running the `ansible-playbook` command or when they are imported in Oracle Linux Automation Manager (OLAM). Example command line:

    $ ansible-playbook -i inventories/hosts.ini ./deploy-ocne.yml
    $ ansible-playbook -i inventories/hosts.ini ./deploy-mod-ociccm.yml

If you setup the inventory file `<playbook-dir>/inventories/hosts.ini` and the `<playbook-dir>/group_vars/all.yml` files before importing as project in OLAM they can be used as imported _SOURCE_ in the OLAM inventory configuration.
