require 'spec_helper'
require_relative "../../lib/mchx/vmlist/server"


describe Vmlist do

  before(:context) do
    prefix = 'spec/data/'
    @kvmhosts = Marshal.load File.open(prefix + 'test_kvmhosts.dumped')
    @clients =  Marshal.load File.open(prefix + 'test_clients.dumped')
    @infrahosts = Marshal.load File.open(prefix + 'infrahosts.dumped')
    @server = VmList::Server.new({})
  end

  it 'get_kvmhosts returns 314 rows from test data correctly' do
    # arrange
    allow(@server).to receive(:_load_kvm_data).and_return(@kvmhosts)
    @server.load_kvmhosts
    # act
    result = @server.get_kvmhosts.count
    #assert
    expect(result).to eq(314)
  end

  it 'loads guests from hosts data' do
    # arrange
    allow(@server).to receive(:_load_kvm_data).and_return(@kvmhosts)
    @server.load_kvmguests
    # act
    result = @server.get_kvmguests.count
    # assert
    expect(result).to eq(314)

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
    hosttemplate = File.open('lib/mchx/vmlist/index.html.erb').read
    index = ERB.new(hosttemplate)
    # act
    result = index.result(@server.get_binding)
    # assert
    expect(result).not_to eq(nil)
  end
end
