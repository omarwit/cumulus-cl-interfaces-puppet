module Cumulus
  module Utils
    # helps set parameter type to integer`
    def munge_integer(value)
      Integer(value)
    rescue ArgumentError
      fail('munge_integer only takes integers')
    end

    def munge_array(value)
      return_value = value
      msg = 'should be array not comma separated string'
      if value.class == String
        raise ArgumentError msg if value.include?(',')
        return_value = [value]
      end
      if return_value.class != Array
        raise ArgumentError 'should be array'
      end
      return_value
    end
  end
end
