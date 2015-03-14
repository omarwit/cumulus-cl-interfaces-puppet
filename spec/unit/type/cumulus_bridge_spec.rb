require 'spec_helper'
require 'pry'
cl_iface = Puppet::Type.type(:cumulus_bridge)

describe cl_iface do
  let :params do
    [
      :name,
      :ipv4,
      :ipv6,
      :alias_name,
      :addr_method,
      :speed,
      :mtu,
      :virtual_ip,
      :virtual_mac,
      :vids,
      :pvid,
      :location,
      :mstpctl_treeprio,
      :vlan_aware,
      :ports,
    ]
  end

  let :properties do
    [:ensure]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(cl_iface.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(cl_iface.parameters).to be_include(param)
    end
  end

  context 'validation' do
    context 'ports parameter' do
      context 'if not set' do
        it { expect { cl_iface.new(:name => 'br0') }.to raise_error }
      end
      context 'if set' do
        it { expect { cl_iface.new(:name => 'br0',
                                   :ports => ['swp1-12']) }.to_not raise_error }
        it 'should be an array' do
          expect { cl_iface.new(:name => 'br0',
                                :ports => "swp1-12, swp13") }.to raise_error
        end
      end
    end

    context 'vrr parameters' do
      context 'if not all vrr parameters are set' do
        it do
          expect { cl_iface.new(:name => 'swp1', :ports => ['swp1-2'],
                                 'virtual_ip' => '10.1.1.1/24') }.to raise_error
        end
        context 'if all vrr parameters are set' do
          it do
            expect { cl_iface.new(:name => 'swp1',
                                  :virtual_ip => '10.1.1.1/24',
                                  :ports => ['swp1-2'],
                                  :virtual_mac => '00:00:5e:00:00:01') }.to_not raise_error
          end
        end
      end
    end
  end
end
