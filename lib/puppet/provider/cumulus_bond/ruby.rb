require 'cumulus/ifupdown2'
Puppet::Type.type(:cumulus_bond).provide :ruby do
  confine operatingsystem: [:cumulus_linux]

  def build_desired_config
    config = Ifupdown2Config.new(resource)
    config.update_members('slaves', 'bond-slaves')
    config.update_addr_method
    config.update_address
    %w(vids pvid).each do |attr|
      config.update_attr(attr, 'bridge')
    end
    %w(mode min_links miimon lacp_rate xmit_hash_policy).each do |attr|
      config.update_attr(attr, 'bond')
    end
    config.update_alias_name
    config.update_vrr
    # attributes with no suffix like bond-, or bridge-
    %w(mstpctl_portnetwork mstpctl_bpduguard clagd_enable clagd_priority
    clagd_args clagd_peer_ip mtu).each do |attr|
      config.update_attr(attr)
    end
    # copy to instance variable
    @config = config
  end

  def config_changed?
    build_desired_config
    Puppet.debug "desired config #{@config.confighash}"
    Puppet.debug "current config #{@config.currenthash}"
    ! @config.compare_with_current
  end

  def update_config
    @config.write_config
  end
end
