class Ifupdown2Config
  attr_accessor :confighash
  def initialize(resource)
    @resource = resource
  end

  def update_addr_method
  end

  def update_address
  end

  def update_attr(suffix=nil)
  end

  # updates alias name in confighash
  def update_alias_name
  end

  # updates vrr config in config hash
  def update_vrr
  end

  ## comparision
  def <=>(another_config)
  end

  def write_config
  end
end
