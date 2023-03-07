---
- node:
    id: {{ hostvars[inventory_hostname]['ansible_default_ipv4']['address'] }}
 
- log-level: info
 
- tcp-listener:
    port: 27199

- control-service:
    service: control
    filename: /var/run/receptor/receptor.sock
 
- work-command:
    worktype: {% if 'control_nodes' or 'hop' in group_names %}local{% else %}ansible-runner{% endif %}{{''}}
    command: /var/lib/ol-automation-manager/venv/awx/bin/ansible-runner
    params: worker
    allowruntimeparams: true
    verifysignature: false
