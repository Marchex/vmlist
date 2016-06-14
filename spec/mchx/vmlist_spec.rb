require 'spec_helper'

describe Vmlist do

  it 'does something useful' do
    s = Vmlist::ServerMgr.new
    expect(s.load_config).to eq('some string')
  end
end
