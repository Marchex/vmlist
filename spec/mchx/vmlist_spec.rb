require 'spec_helper'
require_relative "../../lib/mchx/vmlist/server"


describe Vmlist do

  before(:context) do
    prefix = 'spec/data/'
    @kvmhosts = Marshal.load File.open(prefix + 'test_kvmhosts.dumped')
    @server = VmList::Server.new({})
  end

  it 'get_kvmhosts returns 314 rows from test data correctly' do
    # arrange
    allow(@server).to receive(:_load_kvmhosts).and_return(@kvmhosts)
    @server.load_kvmhosts
    # act
    result = @server.get_kvmhosts.count
    #assert
    expect(result).to eq(314)
  end

  it 'loads guests from hosts data' do
    # arrange
    allow(@server).to receive(:_load_kvmhosts).and_return(@kvmhosts)
    @server.load_kvmguests
    # act
    result = @server.get_kvmguests.count
    # assert
    expect(result).to eq(314)

  end

end
