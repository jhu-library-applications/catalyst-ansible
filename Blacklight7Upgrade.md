# Blacklight 7 Upgrade 

Prereqs: checkout the blacklight-7.0-upgrade branch of the project. Install based on steps in README.md


1. Back up the host config, it is out of sync with what’s in Ansible. You will need to manually replace it after running step 4
	```
	cp /etc/httpd/conf.d/01_catalyst-test.conf (copy this to somewhere safe, maybe even your local machine)
	```
	update the PassengerRuby line to "PassengerRuby /opt/rubies/ruby-2.6.6/bin/ruby"
2. Upgrade Node 
	```
	sudo yum remove -y nodejs npm
	curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -
	sudo yum install -y nodejs
	```
3. Update the jruby version, chruby version and bundler version in Ansible for your environment (prod, stage, test)
	```
	chruby_ruby_version:    "ruby-2.6.6" 	
	## service_bundler_version:    "2.1.4" 
	service_ruby_version: 	"jruby-9.2.13.0" (it is set in inventory/group_vars/all/services.yml)
	```
4. Run the following ansible command:
	```
    ansible-playbook -i inventory/test playbooks/catalyst.yml   --extra-vars="chruby_ruby_version=ruby-2.5.5" -v -K
    ##  this is unnecessary: ansible-playbook playbooks/services_prereqs.yml -i inventory/test  -v -K
    ```
5.  get the lastest bundler, delete the Gemfile.lock file and run bundler again if Gemfile.lock requires a specific version:
	```
	gem install bundler
	```
6. Deploy the app:
	```
	ansible-playbook playbooks/catalyst_install.yml -i inventory/test --extra-vars "app_branch=blacklight-7.0" -v -K
	```
7. Copy the Updated file /etc/httpd/conf.d/01_catalyst.conf from step 1,  ensure file permissions are the same
8. Reboot the server: sudo reboot
9. To initialize the flipper feature for the first time, run db:migrate to create the tables (TODO: add this to playbook):
	```
	RAILS_ENV=production bundle exec rails db:migrate
	```
