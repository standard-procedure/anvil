# frozen_string_literal: true

class Anvil::ServerInstaller::SetHostname < Struct.new(:ssh_connection, :hostname)
  def call
    script = <<-SCRIPT
      hostnamectl set-hostname #{hostname}
      mkdir -p /etc/environment.d
      echo "HOSTNAME=#{hostname}" > /etc/environment.d/99-hostname
    SCRIPT
    ssh_connection.exec! script, "SetHostname"
  end
end
