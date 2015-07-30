require 'spec_helper_acceptance'

describe 'interfaces' do

  context 'valid simple interface' do

    it 'should work with no errors' do
      pp = <<-EOS
        cumulus_interface { 'lo':
          addr_method => 'loopback'
        }

        cumulus_interface { 'eth0':
          addr_method => 'dhcp'
        }

        cumulus_interface { 'swp2':
          ipv4 => ['10.30.1.1'],
          notify => Service['networking'],
        }

        file { '/etc/network/interfaces':
          content => "source /etc/network/interfaces.d/*\n"
        }

        service { 'networking':
          ensure     => running,
          hasrestart => true,
          restart    => '/sbin/ifreload -a',
          enable     => true,
          hasstatus  => false,
          require    => File['/etc/network/interfaces']
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      #expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe interface('swp2') do
      it { should exist }
      it { should have_ipv4_address('10.30.1.1') }
    end

  end

end
