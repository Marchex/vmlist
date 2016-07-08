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
svrs.finalize_servers

# load erb template
hosttemplate = File.open('lib/mchx/vmlist/index.html.erb').read
index = ERB.new(hosttemplate)

# Write index.html
File.open(outdir + 'index.html', 'w') do |f|
  f.write index.result(svrs.get_binding)
end

# Write hosts_and_guests.json
File.open(outdir + 'hosts_and_guests.json', 'w') do |f|
  foo = { 'data' => [],
          'timestamp' => Time.now
  }
  svrs.get_kvmhosts.map { |k,v| foo['data'].push(v) }
  f << foo.to_json
end

File.open(outdir + 'guests.json', 'w') do |f|
  foo = { 'data' => [],
          'timestamp' => Time.now
  }
  svrs.get_kvmguests.map { |k,v|
    foo['data'].push(v)
  }
  f << foo.to_json
end
