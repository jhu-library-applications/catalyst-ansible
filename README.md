# catalyst-ansible

Ansible project to build and deploy [Catalyst](https://github.com/jhu-sheridan-libraries/blacklight-rails), Johns Hopkins University Libraries Blacklight-based library catalog.

This project requires

- Requires Ansible 2.10+ (using import_role)
- Tested with Vagrant 2.2, VirtualBox 6.1, macOS Big Sur

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

Go to lastpass, search for "catalyst-ansible" to retrieve the vault password, and put it in the vault_password_file file

Install the required roles. You may check the `requirements.yml` file for details.

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

### Create and copy SSH keys

We are using our GitHub SSH keys to deploy and provision the development environment. If you
were able to clone the repo above you have setup SSH based login with GitHub. You can
find your public key here: `https://github.com/<github-username>.keys`. Your private
key is stored in the `~/.ssh` folder.


You will need to add your private key to your ssh agent like this (on macOS):
```
ssh-add -K ~/.ssh/id_rsa
```

This article has more detailed instructions for (setting up key forwarding)[https://docs.github.com/en/developers/overview/using-ssh-agent-forwarding] and explains
why using key forwarding simplifies the deployment process.

Put the following in `~/.ssh/config` and add your JHEDID to the User line:

```
# --- Catalyst ---
Host catalyst catalyst.library.jhu.edu
        Hostname catalyst.library.jhu.edu
        User <jhedid>
        ForwardAgent yes
        StrictHostKeyChecking no
# ----------------------------

# --- Catalyst Staging ---
Host catalyst-stage catalyst-stage.library.jhu.edu
        Hostname catalyst-stage.library.jhu.edu
        User <jhedid>
        ForwardAgent yes
        StrictHostKeyChecking no
# ----------------------------

# --- Catalyst Test ---
Host catalyst-test catalyst-test.library.jhu.edu
        Hostname catalyst-test.library.jhu.edu
        User <jhedid>
        ForwardAgent yes
        StrictHostKeyChecking no
# ----------------------------

# --- Catalyst Vagrant ---
Host catalyst-dev.test
	   User <jhedid>
     ForwardAgent yes
	   StrictHostKeyChecking no
Host catsolrmain-dev.test
	   User <jhedid>
     ForwardAgent yes
	   StrictHostKeyChecking no
Host catsolrreplica-dev.test
	   User <jhedid>
     ForwardAgent yes
	   StrictHostKeyChecking no
# ------------------
```

Copy your ssh key to the remote server. You will be prompted to enter your JHED password.

```
ssh-copy-id -i ~/.ssh/id_rsa catalyst-stage
```

Verify that you can ssh to stage without login

```
ssh catalyst-stage
```

## Local Vagrant environment

*NOTE: If using VirtualBox 6.1.28 (at least on a Mac), it is necessary to modify/create the `/etc/vbox/networks.conf` file such that it has one and only one line in it: `* 0.0.0.0/0 ::/0`. See: https://forums.virtualbox.org/viewtopic.php?f=7&t=104218#p507770

1. Edit `setup.yml` to indicate that you are using vagrant:

```yaml
---
- name: create login user for installation & configuration
  hosts: all

  vars:
    using_vagrant: true

  roles:
  - { role: login-user, tags: ['login-user'] }
```

2. Run `vagrant up`

This step will download the VMs and setup the hostnames. If this is your
first time downloading the VMs the amount of time this takes will depend
on your connection speed. After they have been cached this step takes around
2 minutes.

3. Run `ansible-playbook playbooks/catalyst.yml -i inventory/vagrant --extra-vars "app_branch=main”`

Create a key on your local development machine with a generic name:

4. Connect to the VPN. The Vagrant environment relies on servers in the test environment.

5. If the playbook is completed successfully you should be able to visit (catalyst-dev.test)[https://catalyst-dev.test] and
see the catalyst home page after type `thisisunsafe` if you are using Chrome. The local environment uses a
self-signed certificate for `https` which Chrome will block. Other browsers will have different methods of getting
around this.

6. The other applications that are provisioned and deployed by this repo can also be installed locally:

Solr:
```
ansible-playbook playbooks/solr.yml -i inventory/vagrant
```

Services (includes the pull reserves setup):
```
ansible-playbook playbooks/services.yml -i inventory/vagrant
```

Horizon Web Service:
```
ansible-playbook playbooks/horizonws.yml -i inventory/vagrant
```

This has a manual step currently beause it assumes that catalyst has been installed
first:
```
cd /opt/catalyst/current ; cp -a horizon-servlet /opt/catalyst
```

Traject:
```
ansible-playbook playbooks/services_install_traject.yml -i inventory/vagrant
```

## Deployment

The usual tasks of catalyst deployment is to deploy the blacklight-rails app.

### Deploy blacklight-rails

To deploy the blacklight app, run the commands list below. Replace `<branch_or_tag_name_or_commit_hash>` with a release tag, or a branch name. For example, you may use `v1.4.14`, `master`, or `hotfix/v1.4.11`.

You will be prompted to enter a BECOME password. This will be your JHED password.

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

After packaging the war file (See https://github.com/jhu-sheridan-libraries/horizon-holding-info-servlet for instructions), copy the war file in the target directory to blacklight-rails/horizon-servlet/deploy/ws.war

Git commit the new war file. Push it to the remote. Create a new release of Catalyst. Deploy the new release (See steps above).

Then run the ansible playbook `playbooks/horizonws_install.yml` to release the war file. For example,

* To catalyst-prod.library.jhu.edu

```
ansible-playbook playbooks/horizonws_install.yml -i inventory/prod -v -K
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


# Deploy solr main and replica

To local dev vagrant vm
Update your local Vagrantfile and add catsolrmain-dev and catsolrreplica-dev
Update your local inventory/vagrant file and ensure the solr group is present


vagrant up
ansible-playbook playbooks/solr.yml -i inventory/vagrant

Deploy to Test
ansible-playbook playbooks/solr.yml -i inventory/test -v -K

# Changing Service Cron times

To just update the cron configuration for catalyst-traject and catalyst-pull-reserves
```
time ansible-playbook -i inventory/test  playbooks/services_install_traject.yml  --tags=cron -v
```
took 21s

# Deploy traject
```
ansible-playbook -i inventory/test playbooks/services_install_traject.yml --tags=services -v -K
```
