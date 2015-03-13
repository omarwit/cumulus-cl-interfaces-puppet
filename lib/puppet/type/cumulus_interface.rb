require 'puppet/parameter/boolean'
Puppet::Type.newtype(:cumulus_interface) do
  desc 'Config front panel ports, SVI, loopback,
  mgmt ports on Cumulus Linux. To configure a bond use the
  cumulus_bond module. To configure a bridge interface use
  the cumulus_bridge module.
  '
  # helps set parameter type to integer`
  def munge_integer(value)
    Integer(value)
  rescue ArgumentError
    fail("munge_integer only takes integers")
  end

  def munge_array(value)
    return_value = value
    msg = 'should be array not comma separated string'
    if value.class == String
      raise ArgumentError, msg if value.include?(',')
      return_value = [value]
    end
    if value.class != Array
      raise ArgumentError 'should be array'
    end
    return_value
  end

  ensurable do
    newvalue(:outofsync) do
    end
    newvalue(:insync) do
      provider.update_config
    end
    def retrieve
      result = provider.config_changed?
      result ? :outofsync : :insync
    end

    defaultto do
      :insync
    end
  end

  newparam(:name) do
    desc 'interface name'
  end

  newparam(:ipv4) do
    desc 'list of ipv4 addresses
    ip address must be in CIDR format and subnet mask included
    Example: 10.1.1.1/30'
  end

  newparam(:ipv6) do
    desc 'list of ipv6 addresses
    ip address must be in CIDR format and subnet mask included
    Example: 10:1:1::1/127'
  end

  newparam(:alias_name) do
    desc 'interface description'
  end

  newparam(:addr_method) do
    desc 'address assignment method'
    newvalues(:dhcp, :loopback)
  end

  newparam(:speed) do
    desc 'link speed in MB. Example "1000" means 1G'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:mtu) do
    desc 'link mtu. Can be 1500 to 9000 KBs'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:virtual_ip) do
    desc 'virtual IP component of Cumulus Linux VRR config'
  end

  newparam(:virtual_mac) do
    desc 'virtual MAC component of Cumulus Linux VRR config'
  end

  newparam(:vids) do
    desc 'list of vlans. Only configured on vlan aware ports'
    munge do |value|
      @resource.munge_array(value)
    end
  end

  newparam(:pvid) do
    desc 'vlan transmitted untagged across the link (native vlan)'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:location) do
    desc 'location of interface files'
    defaultto '/etc/network/interfaces.d'
  end

  newparam(:mstpctl_portnetwork, :boolean => true,
          :parent => Puppet::Parameter::Boolean) do
    desc 'configures bridge assurance. Ensure that port is in vlan
    aware mode'
  end

  newparam(:mstpctl_bpduguard, :boolean => true,
          :parent => Puppet::Parameter::Boolean) do
    desc 'configures bpdu guard. Ensure that the port is in vlan
    aware mode'
  end

  newparam(:clagd_enable, :boolean => true,
          :parent => Puppet::Parameter::Boolean) do
    desc 'enable CLAG on the interface. Interface must be in vlan \
    aware mode. clagd_enable, clagd_priority, clagd_peer_ip, clagd_sys_mac must be
    configured together'
  end

  newparam(:clagd_priority) do
    desc 'determines which switch is the primary role. The lower priority
    switch will assume the primary role. Range can be between 0-65535.
    clagd_enable, clagd_priority, clagd_peer_ip and clagd_sys_mac must be configured
    together'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:clagd_peer_ip) do
    desc 'clagd peerlink adjacent port IP. clagd_enable, clagd_peer_ip, clagd_sys_mac
    and clagd_sys_mac must be configured together'
  end

  newparam(:clagd_sys_mac) do
    desc 'clagd system mac. Must the same across both Clag switches.
    range should start with 44:38:38:ff. clagd_enable, clagd_peer_ip,
    clagd_sys_mac, clagd_priority must be configured together'
  end

  newparam(:clagd_args) do
    desc 'additional Clag parameters. must be configured with other clagd parameters.
    it is optional'
  end

  validate do
    if self[:clagd_enable].nil? ^ self[:clagd_priority].nil? ^
      self[:clagd_peer_ip].nil? ^ self[:clagd_sys_mac].nil?
      raise Puppet::Error, 'Clagd parameters clagd_enable, clagd_priority,
      clagd_peer_ip and clagd_sys_mac must be configured together'
    end

    unless self[:clagd_args].nil?
      if self[:clagd_enable].nil?
        raise Puppet::Error, 'Clagd must be enabled for clagd_args to be active'
      end
    end
    if self[:virtual_ip].nil? ^ self[:virtual_mac].nil?
      raise Puppet::Error, 'VRR parameters virtual_ip and virtual_mac must be
      configured together'
    end
  end
end
