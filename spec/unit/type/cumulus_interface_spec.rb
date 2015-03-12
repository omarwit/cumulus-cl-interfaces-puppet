require 'spec_helper'

cl_iface = Puppet::Type.type(:cumulus_interface)

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
      :mstpctl_portnetwork,
      :mstpctl_bpduguard,
      :clagd_enable,
      :clagd_priority,
      :clagd_peer_ip,
      :clagd_sys_mac,
      :clagd_args
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
end
