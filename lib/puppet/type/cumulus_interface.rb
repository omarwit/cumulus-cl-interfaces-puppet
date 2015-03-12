Puppet::Type.newtype(:cumulus_interface) do
  @doc = "Config front panel ports, SVI, loopback,
  mgmt ports on Cumulus Linux. To configure a bond use the
  cumulus_bond module. To configure a bridge interface use
  the cumulus_bridge module.
  "
  newproperty(:ensure) do
    desc 'Reflects state of the interface. if "insync" do nothing'

    # default setting set to what it "should be, which is in sync"
    defaultto :insync

    # retrieve function gets current interface config
    # it compares it with the desired state. if there
    # is a different the desired state overwrites the
    # current config
    def retrieve
      prov = @resource.provider
      if prov && prov.respond_to?(:config_changed?)
        result = @resource.provider.config_changed?
      else
        errormsg = 'unable to find a provider for cumulus_interface ' \
          'that has a "config_changed?" function'
        fail Puppet::DevError, errormsg
      end
     result ? :outofsync : :insync

     newvalue :outofsync
     newvalue :insync do
       prov = @resource.provider
       if prov && prov.respond_to?(:update_config)
         prov.update_config
       else
         errormsg = 'unable to find a provider for cumulus_interface ' \
          'that has an "update_config" function'
       end
       nil
     end
    end
  end

  newparam(:name) do
    desc 'interface name'
    isnamevar
  end

  newparam(:ipv4) do
    @doc='list of ipv4 addresses
    ip address must be in CIDR format and subnet mask included
    Example: 10.1.1.1/30'
  end

  newparam(:ipv6) do
    @doc='list of ipv6 addresses
    ip address must be in CIDR format and subnet mask included
    Example: 10:1:1::1/127'
  end

  newparam(:alias_name) do
    desc 'interface description'
  end

  newparam(:addr_method) do
    desc 'address assignment method'
    validate do |value|
      unless value =~ /dhcp|loopback/
        raise ArgumentError,
          "%s entered. acceptable options are 'dhcp' or 'loopback'" % value
      end
    end
  end

  newparam(:speed) do
    desc 'link speed in MB. Example '1000' means 1G'
  end

  newparam(:mtu) do
    desc 'link mtu. Can be 1500 to 9000 KBs'
  end

  newparam(:virtual_ip) do
    desc 'virtual IP component of Cumulus Linux VRR config'
  end

  newparam(:virtual_mac) do
    desc 'virtual MAC component of Cumulus Linux VRR config'
  end

  newparam(:vids) do
    desc 'list of vlans. Only configured on vlan aware ports'
  end

  newparam(:pvid) do
    desc 'vlan transmitted untagged across the link (native vlan)'
  end

  newparam(:location) do
    desc 'location of interface files'
    defaultto '/etc/network/interfaces.d'
  end

  newparam(:mstpctl_portnetwork) do
    @doc='configures bridge assurance. Ensure that port is in vlan
    aware mode'
  end

  newparam(:mstpctl_bpduguard) do
    @doc='configures bpdu guard. Ensure that the port is in vlan
    aware mode'
  end

  newparam(:clagd_enable, :boolean => true,
          :parent => Puppet::Parameter::Boolean) do
    desc 'enable CLAG on the interface. Interface must be in vlan \
    aware mode'
  end

  newparam(:clagd_priority) do
    @doc='determines which switch is the primary role. The lower priority
    switch will assume the primary role. Range can be between 0-65535'
  end

  newparam(:clagd_peer_ip) do
    desc 'clagd peerlink adjacent port IP'
  end

  newparam(:clagd_sys_mac) do
    @doc='clagd system mac. Must the same across both Clag switches.
    range must be with 44:38:38:ff'
  end

  newparam(:clag_args) do
    desc 'additional Clag parameters'
  end
end
