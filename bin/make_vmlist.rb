#!/usr/bin/env ruby

require "bundler/setup"
require_relative "../lib/mchx/vmlist/server_mgr"
require 'erb'
require 'json'



svrs = Vmlist::ServerMgr.new
svrs.load_config('conf/config.json')
outdir = svrs.get_config.first[1]['outputdir']

svrs.init_servers
svrs.poll_servers
# just getting the first server for now; breaks if more than 1 server in config
obj = svrs.get_servers.first[1]

# load erb template
hosttemplate = File.open('lib/mchx/vmlist/index.html.erb').read
index = ERB.new(hosttemplate)

# Write index.html
File.open(outdir + 'index.html', 'w') do |f|
  f.write index.result(obj.get_binding)
end

# Write hosts_and_guests.json
File.open(outdir + 'hosts_and_guests.json', 'w') do |f|
  f << obj.get_kvmhosts.to_json
end

