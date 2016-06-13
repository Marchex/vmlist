require_relative "vmlist/version"
require_relative 'vmlist/chef'


module Vmlist

  server = Vmlist::Chef.new

  puts server.something
end
