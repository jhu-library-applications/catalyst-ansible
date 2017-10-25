# catalyst-ansible

Ansible project to build and deploy [Catalyst](https://github.com/jhu-sheridan-libraries/blacklight-rails), Johns Hopkins University Libraries blacklight-based library catalogue.

## WIP

## deployment

### Deploy catalyst

* To local dev vms
```
vagrant up
ansible-playbook playbooks/catalyst_install.yml -i inventory/vagrant --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash> force_default_jhed=<username>" -v
```
* To catalyst-test.library.jhu.edu
```
ansible-playbook playbooks/catalyst_install.yml -i inventory/stage --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash>" -v
```
* To catalyst-prod.library.jhu.edu

    Update the `app_branch` variable in `inventory/prod/vars.yml`, and commit it and push.
```
ansible-playbook playbooks/catalyst_install.yml -i inventory/prod -v
```
