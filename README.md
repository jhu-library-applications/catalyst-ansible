# catalyst-ansible

Ansible project to build and deploy [Catalyst](https://github.com/jhu-sheridan-libraries/blacklight-rails), Johns Hopkins University Libraries blacklight-based library catalogue.

## WIP

## Setup SSH keys

Here using setting up stage as an example. For other environment, revise accordingly.

Update ansible.cfg and comment out remote_user at the top, and uncomment the
section at the bottom that starts with `# first-run vars for setup.yml:`

ansible-playbook setup.yml -i inventory/stage -v

Change it back afterwards

Update ~/.ssh/config, rename/or add catalyst-stage entry

Then find the ssh passphrase in vault

```
ansible-vault view inventory/group_vars/stage/vault.yml | grep 'vault_login_user_passphrase'
```

Copy the passphrase

ssh to `catalyst-stage.library.jhu.edu` and `catsolrslave-test`. You may need the passphrase that was copied above.

Then you can run the deployment commands below.

## deployment

### Deploy catalyst

* To local dev vms
```
vagrant up
ansible-playbook playbooks/catalyst_install.yml -i inventory/vagrant --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash> force_default_jhed=<username>" -v
```
* To catalyst-test.library.jhu.edu
```
ansible-playbook playbooks/catalyst_install.yml -i inventory/test --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash>" -v
```
* To catalyst-stage.library.jhu.edu
```
ansible-playbook playbooks/catalyst_install.yml -i inventory/stage --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash>" -v
```
* To catalyst-prod.library.jhu.edu

Update the `app_branch` variable in `inventory/prod/vars.yml`, and commit it and push.

```
ansible-playbook playbooks/catalyst_install.yml -i inventory/prod -v
```

### Deploy the web service 

* To catalyst-prod.library.jhu.edu

```
ansible-playbook playbooks/horizonws_install.yml -i inventory/prod -v
```
