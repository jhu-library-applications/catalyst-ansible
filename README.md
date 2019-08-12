# catalyst-ansible

Ansible project to build and deploy [Catalyst](https://github.com/jhu-sheridan-libraries/blacklight-rails), Johns Hopkins University Libraries blacklight-based library catalogue.

This project requires

- Requires Ansible 2.7+ (using import_role)
- Tested with Vagrant 2.0.3, VirtualBox 5.2.8

## Getting Started

Clone the git repo

```
git clone git@github.com:jhu-sheridan-libraries/catalyst-ansible.git
```

Create vault password file

```
mkdir ~/.ssh/catalyst-ansible
touch ~/.ssh/catalyst-ansible/vault_password_file
```

Go to lastpass, find the vault password, and put it in the file

Install the required rols. You may check the `requirements.yml` file for details.

```
ansible-galaxy install -r requirements.yml
```

Create `~/.ansible.ini` if it doesn't exist. Put the following in the file:

```
[cross-project]
remote_user = <jhedid>
login_user  = <jhedid>
login_group = msel-libraryapplications
```

### Set up SSH keys

Creat SSH key, and copy the key to the remote server.  Here're the steps to do it manually. These steps may also be done via Ansible. However, the steps are not documented. You may need to find the documentation on a different project by Drew Heles. 

Here the key is in ~/.ssh/catalyst-ansible. You may also use a generic key in your ~/.ssh directory that was already created.

```
ssh-keygen -t rsa -b 4096 -f ~/.ssh/catalyst_ansible
```

Put the following in `~/.ssh/config`

```
Host catalyst-stage catalyst-stage.library.jhu.edu
        Hostname catalyst-stage.library.jhu.edu
        User <jhedid>
        IdentityFile ~/.ssh/catalyst_ansible
        IdentitiesOnly yes
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null
```

Copy your ssh key to the remote server

```
ssh-copy-id catalyst-stage
```

Verify that you can ssh to stage without login

```
ssh catalyst-stage
```

### Set up the stage

Now you're ready to run the setup script.

```
ansible-playbook -i inventory/stage setup.yml -v
```

Now you're ready to run the deployment scripts.

## deployment

The usually tasks of catalyst deployment is to deploy the blacklight-rails app.

### Deploy blacklight-rails

To deploy the blacklight app, run the commands list below. Replace `<branch_or_tag_name_or_commit_hash>` with a release tag, or a branch name. For example, you may use `v1.4.14`, `master`, or `hotfix/v1.4.11`.

* To catalyst-prod.library.jhu.edu

```
ansible-playbook playbooks/catalyst_install.yml -i inventory/prod --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash>" -v -K
```

* To catalyst-stage.library.jhu.edu

```
ansible-playbook playbooks/catalyst_install.yml -i inventory/stage --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash>" -v -K
```

* To catalyst-test.library.jhu.edu

```
ansible-playbook playbooks/catalyst_install.yml -i inventory/test --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash>" -v -K
```

* To local dev vms
```
vagrant up
ansible-playbook playbooks/catalyst_install.yml -i inventory/vagrant --extra-vars "app_branch=<branch_or_tag_name_or_commit_hash> force_default_jhed=<username>" -v
```


### Deploy the web service

This is very rare. Only necessary if you need to update the Java based web service at https://github.com/jhu-sheridan-libraries/horizon-holding-info-servlet

* To catalyst-prod.library.jhu.edu

```
ansible-playbook playbooks/horizonws_install.yml -i inventory/prod -v
```

## Deploy the Solr servers

The ansible scripts also include steps to upgrade solr servers. This is only necessary when the solr server needs to be updated. So ignore this section most of the time. Also note that this section is not very well maintained. Use with discretion.

To delete all the data from a core
```
curl http://localhost:8983/solr/catalyst/update?commit=true -H "Content-Type: text/xml" --data-binary '<delete><query>*:*</query></delete>'
```

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
