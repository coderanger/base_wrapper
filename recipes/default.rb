#
# Cookbook Name:: base_wrapper
# Recipe:: default
#
#

# Set a counter to track instances
# NOTE: the first instance will be 1
instanceCounter = 0

# Instance deployment
# Most, if not all, references should be made using instance vars
node['base_wrapper']['names'].each do |instanceName|
  #Not idempotent
  #log "Working on instance: #{instanceName}"

  # Assign local hash of all default attributes
  defVars = node['base_wrapper'].to_hash

  # Remove all instance specific attributes from the default hash
  node['base_wrapper']['names'].each do |instanceName|
    defVars.delete(instanceName)
  end

  # create the instance's attribute if set
  if node['base_wrapper'][instanceName] == nil
    node.default['base_wrapper'][instanceName]
  end

  # Assign local hash of all defined instance attributes
  insVars = node['base_wrapper'][instanceName].to_hash

  # Merge default and instance attributes hashes into insVars
  # Instance attributes will trump default ones
  insVars = Base_Wrapper_Util.deep_merge(defVars, insVars)

  # add helper vars to instance hash
  insVars['instanceName'] = instanceName
  insVars['instanceCounter'] = instanceCounter += 1

   # set local master vars
  masterBase = "#{insVars['master']['base']}"
  masterName = "#{insVars['master']['name']}"
  masterRoot = "#{masterBase}/#{masterName}"
  masterWarname = "#{insVars['master']['warname']}"

  # set local path vars
  instanceBase = "#{insVars['tomcat']['serverBase']}"
  instanceRoot = "#{instanceBase}/#{instanceName}"

  # Add restart subscribes if nothing is set on base_wrapper

  if ! insVars['restart_subscribes']
    insVars['restart_subscribes'] = node['base_test']['restart_subscribes']
  end

  # All files managed by chef directly should be excluded
  # Tomcat config files are excluded by default
  # localconfig and files set in manage_cfg are excluded
  masterFileExclude = ["#{masterRoot}/conf/server.xml"]
  masterFileExclude = masterFileExclude + ["#{masterRoot}/conf/web.xml"]
  masterFileExclude = masterFileExclude + ["#{masterRoot}/conf/context.xml"]
  masterFileExclude = masterFileExclude + ["#{masterRoot}/conf/test-users.xml"]
  if insVars['master']['fileExclude']
    insVars['master']['fileExclude'].each do |file|
      masterFileExclude = masterFileExclude +  ["#{masterRoot}/#{file}"]
    end
  end

  # base_test thinks runUser and runGroup should be a thing
  insVars['tomcat']['runUser'] = insVars['user']
  insVars['tomcat']['runGroup'] = insVars['group']

  # test instance files owned by root in base_test
  ownedByRoot = [ "#{instanceRoot}/conf", "#{instanceRoot}/properties" ]

  # create test instance
  # add a test to make sure instanceName is not an empty value
  base_test_instance instanceName do
    insVars['tomcat'].each do |key, value|
      begin
        send(key, value)
      rescue Chef::Exceptions::ValidationFailed => e
        if e.message.include?("must be a kind of Integer") && value =~ /^[0-9]+$/
          send(key, value.to_i)
        else
          raise e.class, "base_test_instance #{key} = #{value} Exception #{e.message}"
        end
      end
    end
  end

    service "crond" do
      supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
      if (node['base_wrapper']['start'] == true) && (node['base_wrapper']['fileChangeRestart'] == true) && (tomcat_running?(insVars['user']))
	insVars['restart_subscribes'].each do |file|
         subscribes :restart, "template[#{instanceRoot}/#{file}]"
        end
      end
      if node['base_wrapper']['enable'] == true
       if (node['base_wrapper']['start'] == true) && !(tomcat_running?(insVars['user']))
           action [:enable, :start]
       else
           action :enable
       end
      else
         action :disable
      end
    end
 end
