**Introduction**
Security Technical Implementation Guide, which is released by The Defense Information Systems Agency (DISA) is a document that provides guidance on configuring a system to meet cybersecurity requirements for deployment within the Department of Defense (DoD) IT network systems. 
The published STIG guidelines have been included in the scap-security-guide package available under ol8_appstream channel, which can be used with the openscap tool for evaluating the compliance of an Oracle Linux installation.
Individual rules and the remediation details are well documented in [ssg-ol8-guide-standard](https://static.open-scap.org/ssg-guides/ssg-ol8-guide-standard.html).
RPM Package scap-security-guide provides the remediation playbooks for different profiles including STIG which is located under /usr/share/scap-security-guide/ansible/ .
This playbook can then be used with Oracle Linux Automation Manager for applying the remediation on group of machines.

**Considersations**
As part of the remediation activtity, there could be many modifications made to the target host. Hence, kindly review each tasks before preoceeding.
Here are the exaples, to list a few:

- DISA-STIG-OL08-00-010550 - Disables SSH root login. SSH session to the servers might give an "Access Denied" error.
- DISA-STIG-OL08-00-010020 - Enables FIPS. Ensure to reboot the host for the FIPS to be enabled. Else, though the remediation is applied, the rule will still be marked as failed.
- DISA-STIG-OL08-00-010670 - Disables kdump services.


