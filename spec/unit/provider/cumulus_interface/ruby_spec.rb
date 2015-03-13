require 'spec_helper'
require 'pry'

provider_resource = Puppet::Type.type(:cumulus_interface)
provider_class = provider_resource.provider(:ruby)

describe provider_class do
  before(:all) do
    # this is not a valid entry to use in a real scenario..
    # only designed for testing
    @resource = provider_resource.new(
      name: 'swp1',
      vids: ['1-10', '20'],
      speed: 1000,
      ipv4: ['10.1.1.1/24'],
      ipv6: ['10:1:1::1/127'],
      addr_method: 'loopback',
      alias_name: 'my int description',
      virtual_ip: '10.1.1.1/24',
      virtual_mac: '00:00:5e:00:00:01',
      mstpctl_bpduguard: true,
      mstpctl_portnetwork: false,
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
    context 'addr_method' do
      subject { confighash['addr_method'] }
      it { is_expected.to eq 'loopback' }
    end
    context 'addr_family' do
      subject { confighash['addr_family'] }
      it { is_expected.to eq 'inet' }
    end
    context 'interface description - alias' do
      subject { confighash['config']['alias'] }
      it { is_expected.to eq 'my int description' }
    end
    context 'vrr config' do
      subject { confighash['config']['address-virtual'] }
      it { is_expected.to eq '00:00:5e:00:00:01 10.1.1.1/24' }
    end
    context 'generic attr that is a true bool' do
      subject { confighash['config']['mstpctl-bpduguard'] }
      it { is_expected.to eq 'yes' }
    end
    context 'generic attr is a false bool' do
      subject { confighash['config']['mstpctl-portnetwork'] }
      it { is_expected.to eq 'no' }
    end
  end
end
