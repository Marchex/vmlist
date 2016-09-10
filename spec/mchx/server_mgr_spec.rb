require 'spec_helper'
require_relative "../../lib/vmlist/server"

describe 'Vmlist::ServerMgr' do

  before(:context) do
    prefix = 'spec/data/'
    @kvmhosts = Marshal.load File.open(prefix + 'test_kvmhosts.dumped')
    @clients =  Marshal.load File.open(prefix + 'test_clients.dumped')
    @infrahosts = Marshal.load File.open(prefix + 'infrahosts.dumped')
    @server = VmList::Server.new({})
  end

  it 'renders the main erb file' do
    # arrange
    allow(@server).to receive(:_load_kvm_data).and_return(@kvmhosts)
    allow(@server).to receive(:_load_clients).and_return(@clients)
    allow(@server).to receive(:_load_infrahosts).and_return(@infrahosts)
    @server.load_kvmhosts
    @server.load_kvmguests
    @server.load_clients
    @server.load_infrahosts
    hosttemplate = File.open('lib/vmlist/index.html.erb').read
    index = ERB.new(hosttemplate)
    # act
    result = index.result(@server.get_binding)
    # assert
    expect(result).not_to eq(nil)
  end
end