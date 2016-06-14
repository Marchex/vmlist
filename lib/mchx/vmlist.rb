require_relative "vmlist/version"
require_relative 'vmlist/server_mgr'


module Vmlist

  svrs = Vmlist::ServerMgr.new
  svrs.load_config
  svrs.init_servers
  svrs.poll_servers
  foo = svrs.get_servers_list

  foo
end
