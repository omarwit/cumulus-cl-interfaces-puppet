require 'cumulus/ifupdown2'
Puppet::Type.type(:cumulus_interface).provide :ruby do
  #confine operatingsystem: [:cumulus_linux]

  def build_desired_config
    desired_config = Ifupdown2Config.new(resource)
    desired_config.update_addr_method
    desired_config.update_address
    %w(vids pvid).each do |attr|
      desired_config.update_attr(attr, 'bridge')
    end
    desired_config.update_alias_name
    desired_config.update_vrr
    # attributes with no suffix like bond-, or bridge-
    %w(mstpctl-portnetwork mstpctl-bpduguard clagd_enable clagd_priority
    clagd_args clagd_peer_ip).each do |attr|
      desired_config.update_attr(attr)
    end
    # copy to instance variable
    @desired_config = desired_config
  end

  def config_changed?
    @current_config = Ifupdown2Config.new(resource)
    build_desired_config
    (@current_config == @desired_config) ? :outofsync : :insync
  end

  def update_config
    @desired_config.write_config
  end
end
