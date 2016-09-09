#!/usr/bin/env ruby

require 'bundler/setup'
require '../lib/mchx/vmlist/server'


def writeout(filename, object)
  output = File.open( filename, "w" )
  output << object
  output.close
end


svrs = Vmlist::ServerMgr.new
svrs.load_config('conf/config.json')
outdir = svrs.get_config.first[1]['outputdir']

svrs.init_servers
svrs.poll_servers
svrs.finalize_servers

prefix = '../spec/data/'
writeout prefix + 'test_clients.dumped', Marshal.dump(obj.get_clients)
writeout prefix + 'test_kvmhosts.dumped', Marshal.dump(obj._load_kvm_data)
writeout prefix + 'infrahosts.dumped', Marshal.dump(obj.get_infrahosts)