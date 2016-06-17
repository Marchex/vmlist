#!/usr/bin/env ruby

require "bundler/setup"
require_relative "../lib/mchx/vmlist/server"
require 'erb'
require 'json'

hosttemplate = File.open('lib/mchx/vmlist/index.html.erb').read
index = ERB.new(hosttemplate)

obj = VmList::Server.new({'endpoint' =>  'https://api.opscode.com/organizations/marchex',
                          'client' => 'jciimarchex',
                          'key' => '/Users/jcarter/.chef/jciimarchex.pem'})

obj.connect
obj.load_clients
obj.load_kvmhosts
obj.load_kvmguests
obj.load_infrahosts
obj.filter_stopped_guests
obj.remove_base_guests
obj.finalize

# Write index.html
File.open('index.html', 'w') do |f|
  f.write index.result(obj.get_binding)
end

# Write hosts_and_guests.json
File.open('hosts_and_guests.json', 'w') do |f|
  f << obj.get_kvmhosts.to_json
end

