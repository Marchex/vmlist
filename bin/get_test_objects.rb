#!/usr/bin/env ruby

require "bundler/setup"
require "../lib/mchx/vmlist/server"


def writeout(filename, object)
  output = File.open( filename, "w" )
  output << object
  output.close
end

prefix = '../spec/data/'

obj = VmList::Server.new({'endpoint' =>  'https://api.opscode.com/organizations/marchex',
                          'client' => 'jciimarchex',
                          'key' => '/Users/jcarter/.chef/jciimarchex.pem'})

obj.connect

obj.load_clients
writeout prefix + "test_clients.dumped", Marshal.dump(obj.get_clients)

obj.load_kvmhosts
writeout prefix + 'test_kvmhosts.dumped', Marshal.dump(obj.get_kvmhosts)

#obj.load_kvmguests
#obj.get_kvmguests

obj.load_infrahosts
writeout prefix + 'infrahosts.dumped', Marshal.dump(obj.get_infrahosts)