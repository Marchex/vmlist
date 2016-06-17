require 'chef-api'
require_relative 'host'
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
      @clients = _load_clients
    end

    def _load_clients
      @cnxn.clients.list
    end

    def _load_kvm_data
      temp = @cnxn.partial_search.query(:node,
               {
                   # the entries in these arrays translate into nodes in the
                   # json data structure; they restrict the data returned by the server
                   # and improve performance
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
               # the solr search criteria
               'virtualization_system:kvm AND virtualization_role:host',
               start: 0)
      temp.rows
    end

    def load_kvmhosts
      @kvmhosts = {}
      data = _load_kvm_data
      data.each do |x|
        @kvmhosts.store x['name'], VmList::KvmHost.new(x)
      end
    end

    def load_kvmguests
      load_kvmhosts if @kvmhosts.nil? || @kvmhosts.empty?
      @kvmguests = {}
      @kvmhosts.each do |k,v|
        @kvmguests.store(k,  v.guests)
      end
      @kvmguests
    end

    def load_infrahosts
      @infrahosts = {}
      data = _load_infrahosts
      data.each do |x|
        @infrahosts.store x['fqdn'], x
      end
    end

    def _load_infrahosts
      temp = @cnxn.partial_search.query(:node, {fqdn: ['name'] }, 'roles:infra', start: 0)
      temp.rows
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

    def filter_stopped_guests
      @kvmguests.each do |k,v|
        v.each do |y,z|
          if z['state'] == "shut" then
            shutcpu = z['CPU(s)'].to_i
            shutmem = z['Max memory'].to_i / 1048576

            @kvmhosts[k].guest_cpu_total = @kvmhosts[k].guest_cpu_total - shutcpu unless @kvmhosts[k].guest_cpu_total == 0
            @kvmhosts[k].guest_maxmem_total = @kvmhosts[k].guest_maxmem_total - shutmem unless @kvmhosts[k].guest_maxmem_total == 0
          end
        end
      end
    end

    def remove_base_guests
      @kvmguests.values.each do |guest|
        guest.delete_if {|k| k =~ /base|template/}
      end
    end

    def finalize
      @kvmhosts.each do |k, v|
        v.finalize
      end
    end

    def get_binding
      binding
    end
  end
end