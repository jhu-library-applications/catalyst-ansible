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

### Server Component Upgrades

#### Upgrade Ruby
We assume that the application has been tested on dev, and either  test/stage.

Follow the following checklist
* Update the production inventory, choose ruby version, and app_branch
* Check you have ssh deploy@catalyst.library.jhu.edu works
* Check free space on server (df -h ) | require at least 2G
* Run the catalyst.yml playbook on production
```
time ansible-playbook -i inventory/prod playbooks/catalyst.yml  --limit=catalyst -v
```
* This takes 13m to run, 4m of downtime
* Keep an eye on the logs for errors
* Run the cucumber test locally

Note: Fallback plan you can pass in the ruby, and app version to revert.
```
#Role Back
time ansible-playbook -i inventory/prod playbooks/catalyst.yml   --extra-vars="app_branch=v1.1.4"  --extra-vars="chruby_ruby_version=ruby-2.2.2" --limit=catalyst -v  # 2m23s
```

For MacOSX 10.13.3 updated the default python which has introduced an issue with python affecting [ansible #32499](https://github.com/ansible/ansible/issues/32499)
```
TASK [jetty : get jetty checksum] *******************************************************************
objc[86359]: +[__NSPlaceholderDate initialize] may have been in progress in another thread when fork() was called.
objc[86359]: +[__NSPlaceholderDate initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```
As a workaround, adding the 'export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES' to your ~/.profile.
A fix mas been merged into the unreleased ansible-2.5 branch.

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

Solr

To delete all the data from a core 
```
curl http://localhost:8983/solr/catalyst/update?commit=true -H "Content-Type: text/xml" --data-binary '<delete><query>*:*</query></delete>'
```

# Deploy solr master and slave

To local dev vagrant vm
Update your local Vagrantfile and add catsolrmaster-dev and catsolrslave-dev
Update your local inventory/vagrant file and ensure the solr group is present


vagrant up
ansible-playbook playbooks/solr.yml -i inventory/vagrant

# Changing Service Cron times

To just update the cron configuration for catalyst-traject and catalyst-pull-reserves 
```
time ansible-playbook -i inventory/test  playbooks/services_install_traject.yml  --tags=cron -v
```
took 21s
