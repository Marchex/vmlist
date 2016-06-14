require 'chef-api'

module VmList
  class Server
    @conf = {}

    def initialize(config)
      @conf = config
      @cnxn = {}
      @clients = []
      @kvmhosts = {}
      @kvmguests = {}
      @infrahosts = {}
    end

    def get_config
      @conf
    end

    def connect
      @cnxn = ChefAPI::Connection.new(
          endpoint: @conf['endpoint'],
          client:   @conf['client'],
          key:      @conf['key']
      )
    end

    def get_connection
      @cnxn
    end

    def load_clients
      @clients = @cnxn.clients.list
    end

    # nodes = Spice.nodes(:q => "virtualization_system:kvm AND virtualization_role:host")
    def load_kvmhosts
      @kvmhosts = @cnxn.partial_search.query(:node,
                       {
                           name:               [ 'name'],
                           cpu_total:          [ 'cpu', 'total' ],
                           guest_cpu_total:    [ 'virtualization', 'kvm', 'guest_cpu_total'],
                           memory:             [ 'memory', 'total' ],
                           guest_maxmem_total: [ 'virtualization', 'kvm', 'guest_maxmemory_total'],
                           platform:           [ 'platform' ],
                           platform_version:   [ 'platform_version' ],
                           guests:             [ 'virtualization', 'kvm', 'guests' ],
                           use:                [ 'system_attrs', 'host_use' ]
                       },
                       'virtualization_system:kvm AND virtualization_role:host',
                       start: 1)

      puts @kvmhosts
    end

    def load_kvmguests
      @kvmguests = Hash[[ *@kvmhosts.rows.map {|x| [ x['name'], x['guests'] ] }]]
    end

    def load_infrahosts
      @infrahosts = @cnxn.partial_search.query(:node, {fqdn: ['name'] }, 'roles:infra', start: 1)
    end

    def get_clients
      @clients
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