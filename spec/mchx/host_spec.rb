require 'spec_helper'
require_relative "../../lib/vmlist/server"

describe 'Vmlist::Host' do

  before(:context) do
    prefix = 'spec/data/'
    @kvmhosts = Marshal.load File.open(prefix + 'test_kvmhosts.dumped')
    @clients =  Marshal.load File.open(prefix + 'test_clients.dumped')
    @infrahosts = Marshal.load File.open(prefix + 'infrahosts.dumped')
    @server = VmList::Server.new({})
  end

  it 'parses an object into json' do
    # arrange
    allow(@server).to receive(:_load_kvm_data).and_return(@kvmhosts)
    @server.load_kvmhosts
    host = @server.get_kvmhosts.first
    # act
    result = host.to_json
    # assert
    expect(result).wont_be_nil
  end
end