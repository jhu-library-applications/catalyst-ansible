# Blacklight 7 Ansible / Manual Upgrade Steps



1. Back up the host config, it is out of sync with what’s in Ansible. You will need to manually replace it after running step 4
	```
		cp /etc/httpd/conf.d/01_catalyst-test.conf (copy this to somewhere safe, maybe even your local machine)
	```
2. Upgrade Node 
	```
		sudo yum remove -y nodejs npm
		curl -sL https://rpm.nodesource.com/setup_12.x | bash -
	```
3. Update the jruby version and chruby version in Ansible for your environment (prod, stage, test)
	```
	chruby_ruby_version:    "ruby-2.5.5" 	service_bundler_version:    "2.1.4"
	```
4. Run the following ansible command:
	```
    ansible-playbook -i inventory/test playbooks/catalyst.yml   --extra-vars="app_branch=feature/curb-side"  --extra-vars="chruby_ruby_version=ruby-2.5.5" -v -K
    ansible-playbook playbooks/services_prereqs.yml -i inventory/test  -v -K
    ```
5. Update the host config with back up from step 1 if you copy the ensure file permissions are the same
6. Deploy the app:
	```
	ansible-playbook playbooks/catalyst_install.yml -i inventory/test --extra-vars "app_branch=blacklight-7.0" -v -K
	```
