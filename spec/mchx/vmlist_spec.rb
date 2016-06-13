require 'spec_helper'

describe Vmlist do
  it 'has a version number' do
    expect(Vmlist::VERSION).not_to be nil
  end

  it 'does something useful' do
    s = Vmlist::Chef.new
    expect(s.something).to eq('some string')
  end
end
