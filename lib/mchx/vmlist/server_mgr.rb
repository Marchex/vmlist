require 'json'
require 'pp'
require_relative 'server'

module Vmlist
  class ServerMgr
    def initialize
      @conf = {}
      @svrs = {}
      @client_map = {}

      @kvmhosts = {}
      @kvmguests = {}
      @infrahosts = {}
    end

    def load_config(file = 'config.json')
      @conf = JSON.parse(IO.read(file))
    end

    def get_config
      @conf
    end

    def init_servers
      @conf.each do |name,config|
        @svrs[name] = VmList::Server.new(name, config, self)
        @svrs[name].connect
      end

    end

    def poll_servers
      @svrs.each do |name,svr|
        svr.load_clients
        svr.get_clients.each do |c| @client_map[c] = name end
        svr.load_kvmhosts
        svr.remove_base_guests
      end
    end

    def get_client_map
      @client_map
    end

    def finalize_servers
      @svrs.each do |name,svr|
        svr.load_kvmguests
        svr.load_infrahosts
        svr.filter_stopped_guests
        svr.finalize
        @kvmhosts   = @kvmhosts.merge(svr.get_kvmhosts)
        @kvmguests  = @kvmguests.merge(svr.get_kvmguests)
        @infrahosts = @infrahosts.merge(svr.get_infrahosts)
      end
    end

    def get_servers
      @svrs
    end

    def get_binding
      binding
    end

    def get_kvmhosts
      @kvmhosts
    end

    def get_kvmguests
      @kvmguests
    end

    def get_infrahosts
      @infrahosts
    end
  end
end