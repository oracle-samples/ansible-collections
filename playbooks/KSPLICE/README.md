# Ksplice - Oracle Linux Ksplice Ansible Playbooks


A collection of playbooks to install Ksplice zero downtime patching on Oracle Linux servers. Ksplice is an Oracle Linux Premier Support service.

Ksplice is available in online or offline deployment scenarios for kernel patching and/or userland patching. Ksplice Uptrack is the kernel patching client, while Ksplice Enhanced is the kernel and userland patching client.

# Ksplice Uptrack check

Playbook: `ksplice-uptrack-check.yml`

Ksplice Uptrack check is a playbook to scan for Common Vulnerabilities and Exposures (CVE). By using the option `save_ouput == "yes"` in  the Job template, the playbook saves the output in HTML format in the `/tmp` directory of the target server. If you run the playbook with the CLI, the “-e” or “–extra-vars” command line parameter for ansible-playbook should be used.

# Ksplice Uptrack offline client

Playbook: `ksplice-uptrack-offline.yml`

The offline version of the Ksplice Uptrack Client removes the requirement that a server on your intranet has a direct connection to the Oracle Uptrack server or ULN. Prior to configuring an offline client, you must set up a local ULN mirror with Ksplice repositories synced from ULN Network.

The URL of the local Ksplice repository on the ULN mirror must be configured as variable in the playbook.

When the playbook is finished, Ksplice is configured to do daily checks for new Ksplice updates (`/etc/cron.daily/uptrack-updates`). When new updates are available they are applied automatically. Configure `skip_apply_after_pkg_install` to `true` to turn of automatic patch upgrades.

## Variables in Ksplice Uptrack offline playbook

| Variable | Default | Description |
| -------- | -------- | ----------- |
| baseurl_ksplice |  | URL to the local ULN mirror, eg http://localyum.example.com/repo/ol{{ ol_version }}_x86_64_ksplice
| install_on_reboot | yes | Automatically install earlier applied updates at boot time
| upgrade_on_reboot | yes | Automatically install all (earlier applied and new) available updates at boot time
| skip_apply_after_pkg_install | false | Set to `true` to avoid automatically running `uptrack-upgrade --all -y` when the uptrack-updates are installed through yum/dnf

# Ksplice Uptrack online client

Playbook: `ksplice-uptrack-online.yml`

The Ksplice Uptrack online playbook requires a server to be registered at the ULN Network. Also the server needs to be subscribed to the Ksplice for Oracle Linux (eg `ol7_x86_64_ksplice` for Oracle Linux 7) ULN channel.

## Variables in Ksplice Uptrack online playbook

| Variable | Default | Description |
| -------- | -------- | ----------- |
| install_on_reboot | yes | Automatically install earlier applied updates at boot time
| upgrade_on_reboot | yes | Automatically install all (earlier applied and new) available updates at boot time
| autoinstall | yes | Enables automatic installation of Ksplice updates, set to `no` for manual Ksplice updates
| https_proxy | None | Proxy to use when accessing the Ksplice Uptrack server, the proxy must support making HTTPS connections
| first_update | true | Runs the first `uptrack-upgrade` at the end of the playbook, set to false when you want to run the first `uptrack-upgrade` manually


