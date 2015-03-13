require 'spec_helper'
require 'pry'

provider_resource = Puppet::Type.type(:cumulus_interface)
provider_class = provider_resource.provider(:ruby)

describe provider_class do
  before(:all) do
    @resource = provider_resource.new(
      name: 'swp1',
      vids: ['1-10', '20'],
      speed: 1000,
      ipv4: ['10.1.1.1/24'],
      ipv6: ['10:1:1::1/127']
    )
    @provider = provider_class.new(@resource)
  end

  context 'desired config hash' do
    let(:confighash) { @provider.instance_variable_get("@config").confighash }
    before  do
      @provider.build_desired_config
    end
    context 'bridge options' do
      subject { confighash['config']['bridge-vids'] }
      it { is_expected.to eq "1-10 20" }
    end
    context 'link speed options' do
      subject { confighash['config']['link-speed'] }
      it { is_expected.to eq "1000" }
    end
    context 'link duplex options' do
      subject { confighash['config']['link-duplex'] }
      it { is_expected.to eq 'full' }
    end
    context 'address options' do
      subject { confighash['config']['address'] }
      it { is_expected.to eq '10.1.1.1/24 10:1:1::1/127' }
    end
  end
end
