require 'cumulus/ifupdown2'
Puppet::Type.type(:cumulus_interface).provide :ruby do
  confine operatingsystem: [:cumulus_linux]
end
