Ansible Role: Service
=========

Deploys a ruby-based service, configures it as needed and creates a cron job to run it.
Currently, this is a local role within the catalyst-ansible project used to deploy
traject and pull-reserves.


Requirements
------------

None


Role Variables
--------------

TBD


Dependencies
------------

As this is a local role, it depends on a number of things from its containing project.


Example Playbook
----------------

    - hosts: traject
      roles:
         - { role: local.service, x: 42 }
    - hosts: webservers
      tasks:
      - include_role:
        name: local.service
          vars:
            app_name: 'traject'

License
-------

CC0
