
# Automating Leapp Upgrades Using Oracle Linux Automation Manager

With the help of the following playbooks let's understand how the process of Leapp Upgrade from Oracle Linux 7 to Oracle Linux 8 as documented in https://docs.oracle.com/en/operating-systems/oracle-linux/8/leapp/leapp-AboutLeapp.html#about-leapp can be automated:

* leapp_prepare.yml: Enables leapp repositories, install the leapp related pacakges, performs a yum update and prepares the system for the leapp updgrade.
* leapp_preupgrade.yml: Run the leapp Preupgrade phase, displays the inhibitors and the answer file.
* leapp_upgrade.yml: Performs the upgrade and reboots the machine.
* post_upgrade.yml: Checks the system and removes any residual Oracle Linux 7 packages.

## Variables

| Variable | Required | Description |
| -------- | -------- | ----------- |
| proxy | Yes | Values: True or False. Specifies if a proxy needs to be used.
| my_https_proxy | Optional | If proxy is set to true, this variable takes the input of proxy.
| leapp_switch | Yes | Values : --oraclelinux or --oci

## Steps

### Oracle Linux Automation Manager
  
  * Ensure the credentials, Inventories and Projects are created.
  * Create a template for each of the four playbooks mentioned above. To simplify the process further, Create a Workflow template in the order leapp_prepare --> leapp_preupgrade --> leapp_upgrade --> leapp_posyupgrade.
  * Add the extra variables as required to each template. Example : {"leapp_swicth":"--oraclelinux"}

### Ansible

* Ensure Inventory file is created/updated pointing to the target hosts.
* Execute each of the playbooks with commands similar to below:
```
#ansible-playbook leapp_prepare.yml -e '{"proxy":"yes","my_https_proxy":"http://proxy:proxyport"}'
#ansible-playbook leapp_preupgrade.yml -e '{"leapp_switch":"--oraclelinux","my_https_proxy":"http://proxy:proxyport"}'
#ansible-playbook leapp_upgrade.yml -e '{"leapp_switch":"--oraclelinux"}'
```


  

