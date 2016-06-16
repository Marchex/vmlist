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

    def _load_kvmhosts
      temp = @cnxn.partial_search.query(:node,
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
      result = {}
      temp.rows.each do |x|
        result.store(x['name'], x)
      end
      result
    end

    def load_kvmhosts
      @kvmhosts = _load_kvmhosts
    end

    def load_kvmguests
      load_kvmhosts if @kvmhosts.nil? || @kvmhosts.empty?
      @kvmguests = {}
      @kvmhosts.each do |k,v|
        @kvmguests.store(k,  v['guests'])
      end
      @kvmguests
    end

    def load_infrahosts
      temp = @cnxn.partial_search.query(:node, {fqdn: ['name'] }, 'roles:infra', start: 1)
      @infrahosts = temp.rows
    end

    def get_clients
      @clients
    end

    def set_clients(clients)
      @clients = clients
    end

    def get_kvmhosts
      @kvmhosts
    end

    def set_kvmhosts(hosts)
      @kvmhosts = hosts
    end

    def get_kvmguests
      @kvmguests
    end

    def get_infrahosts
      @infrahosts
    end

    def set_infrahosts(hosts)
      @infrahosts = hosts
    end

    def massage_cpu_data
      @kvmguests.each do |k,v|
        v.each do |y,z|
          if z['state'] == "shut" then
            shutcpu = z['CPU(s)'].to_i
            shutmem = z['Max memory'].to_i / 1048576

            @kvmhosts[k]['cpu'][1] = @kvmhosts[k]['cpu'][1] - shutcpu unless @kvmhosts[k]['cpu'][1] == 0
            @kvmhosts[k]['memory'][1] = @kvmhosts[k]['memory'][1] - shutmem unless @kvmhosts[k]['memory'] == 0
          end
        end
      end
    end

    def remove_base_guests
      @kvmguests.values.each do |guest|
        guest.delete_if {|k| k =~ /base|template/}
      end
    end

  end
end