require 'json'
class Ifupdown2Config
  attr_accessor :confighash, :currenthash
  def initialize(resource)
    @resource = resource
    @confighash = {
      "addr_family" => nil,
      "addr_method" => nil,
      "auto" => true,
      "name" => resource[:name],
      "config" => {}
    }
    if_to_hash
  end

  ##
  # Use ifquery to generate a JSON representation of an interface and
  # return the hash.
  #
  def if_to_hash
    json = ''
    IO.popen("/sbin/ifquery #{@resource[:name]} -o json") do |ifquery|
      json = ifquery.read
    end
    @currenthash = JSON.parse(json)[0]
  rescue Exception => ex
    Puppet.warning("ifquery failed: #{ex}")
  end

  def compare_with_current
    @confighash == @currenthash
  end

  ##
  # Use ifquery to generate a configuration from a hash and return the
  # configuration.
  #
  def hash_to_if
    intf = ''
    cmd = "/sbin/ifquery -i - -t json #{@resource[:name]}"
    IO.popen(cmd, mode="r+") do |ifquery|
      ifquery.write([@confighash].to_json)
      ifquery.close_write
      intf = ifquery.read
      ifquery.close
    end
    Puppet.debug("hash_to_if hash before text:\n#{@confighash}")
    Puppet.debug("hash_to_if ifupdown2 text:\n#{intf}")
    intf
  rescue Exception => ex
    Puppet.warning("ifquery failed: #{ex}")
  end

  def update_addr_method
    unless @resource[:addr_method].nil?
      Puppet.info "updating address method"
      @confighash["addr_method"] = @resource[:addr_method]
      @confighash["addr_family"] = "inet"
    end

  end

  def update_address
    addresslist = []
    unless @resource[:ipv4].nil?
      Puppet.debug "updating ipv4 info #{@resource[:name]}"
      addresslist +=  @resource[:ipv4].join(' ')
    end
    unless @resource[:ipv6].nil?
      Puppet.debug "updating ipv6 info #{@resource[:name]}"
      addresslist += @resource[:ipv6].join(' ')
    end
    unless addresslist.empty?
      @confighash["config"]["address"] = addresslist
    end
  end

  def update_attr(attr, suffix=nil)
    resource_value = @resource[attr.to_sym]
    ifupdown_value = ''
    if resource_value.nil?
      return
    end
    if resource_value == true
      ifupdown_value = 'yes'
    elsif resource_value ==  false
      ifupdown_value = 'no'
    elsif resource_value.kind_of?(Array)
      ifupdown_value = resource_value.join(' ')
    else
      ifupdown_value = resource_value
    end
    # ifquery uses dash not underscore to define attributes
    attr.sub! '_' , '-'
    configattr = (suffix.nil?) ? attr : "#{suffix}-#{attr}"
    @confighash['config'][configattr] = ifupdown_value
  end

  # updates alias name in confighash
  def update_alias_name
    unless @resource[:alias_name].nil?
      Puppet.debug "updating alias #{@resource[:name]}"
      @confighash["config"]["alias"] = @resource[:alias_name]
    end
  end

  # updates vrr config in config hash
  def update_vrr
    unless @resource[:virtual_ip].nil?
      vrrstring = @resource[:virtual_mac] + ' ' + @resource[:virtual_ip]
      @confighash["config"]["address-virtual"] = vrrstring
      Puppet.debug "updating vrr config #{vrrstring}"
    end
  end

  ## comparision
  def ==(another_config)
    @confighash == another_config.confighash
  end

  # convert hash to text using ifquery
  # write to interfaces file
  def write_config
    Puppet.debug "update config for #{@resource[:name]}"
    intf = hash_to_if
    filepath = @resource[:location] + "/" +  @resource[:name]
    Puppet.debug "file location: #{filepath}"
    begin
      ifacefile = File.open(filepath, "w")
      ifacefile.write(intf)
    ensure
      ifacefile.close
    end
  end
end
