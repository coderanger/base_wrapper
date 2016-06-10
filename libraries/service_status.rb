class Chef
  class Resource
   class Service
   include Chef::Mixin::ShellOut
    def tomcat_running?(user)
        cmd = shell_out!("pgrep -n -u #{user} -f crond", {:returns => [0,1,2]})
        cmd.exitstatus == 0
    end
   end
 end
end
class Chef
  class Resource
   class YumPackage
   include Chef::Mixin::ShellOut
    def tomcat_running?(user)
        cmd = shell_out!("pgrep -n -u #{user} -f crond", {:returns => [0,1,2]})
        cmd.exitstatus == 0
    end
   end
 end
end
