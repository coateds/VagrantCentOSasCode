default['log-file']['path'] = '/home/vagrant/chef_provision.log'

default['hello_web']['package'] = 'httpd'
default['hello_web']['service'] = 'httpd'
default['hello_web']['docroot'] = '/var/www/html'