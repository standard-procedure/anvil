# frozen_string_literal: true

class Anvil::ServerInstaller::ConfigureSshServer < Struct.new(:ssh_connection)
  def call
    script = <<-SCRIPT
      sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
      sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
      service sshd restart
    SCRIPT
    ssh_connection.exec! script
  end
end
