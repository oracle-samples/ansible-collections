# Ksplice - Oracle Linux Ksplice Ansible Playbooks

A collection of playbooks to install Ksplice zero downtime patching on Oracle Linux servers. Ksplice is available to Oracle Linux Premier Support customers.

Ksplice is available in online and offline deployment scenarios for kernal patching and userland patching. Ksplice Uptrack is the kernel patching client, while Ksplice Enhanced is the kernel and userland patching client.

# Ksplice Uptrack offline client

The offline version of the Ksplice Uptrack client removes the requirement that a server on your intranet has a direct connection to the Oracle Uptrack server or ULN. Prior to configuring an offline client, you must set up a local ULN mirror that can act as a Ksplice mirror. The URL of the Ksplice repository on the Local ULN mirror ir required in the variables of the playbook.

When the playbook is finished, Ksplice is configured to run daily to check for new Ksplice updates (`/etc/cron.daily/uptrack-updates`). When new updates are available they are applied automatically. Configure `skip_apply_after_pkg_install` to `true` to turn of automatic patch upgrades.

## Variables in playbook

| Variable | Default | Description |
| -------- | -------- | ----------- |
| ol_version | dynamic | Major version of the OS, `ansible_facts['distribution_major_version']`
| baseurl_ksplice |  | URL to the local ULN mirror, eg http://localyum.example.com/repo/ol7_x86_64_ksplice
| install_on_reboot | yes | Automatically install earlier applied updates at boot time
| upgrade_on_reboot | yes | Automatically install all (earlier applied and new) available updates at boot time
| skip_apply_after_pkg_install | false | True to avoid yum automatically running `uptrack-upgrade --all -y` when the uptrack-updates are installed through yum/dnf

