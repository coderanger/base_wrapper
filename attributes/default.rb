# hostname attrs
default['base_wrapper']['fqdn'] = node[:fqdn]
default['base_wrapper']['hostname'] = node[:hostname]
default['base_wrapper']['domain'] = node[:domain]

default['base_wrapper']['user'] = 'root'
default['base_wrapper']['group'] = 'root'

# base_tomcat_instance settings
default['base_wrapper']['tomcat']['serverBase'] = '/data/servers'
default['base_wrapper']['tomcat']['start'] = false
default['base_wrapper']['tomcat']['fileChangeRestart'] = false

# service settings
default['base_wrapper']['enable'] = true
default['base_wrapper']['start'] = true
default['base_wrapper']['fileChangeRestart'] = true

