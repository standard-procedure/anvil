# frozen_string_literal: true

class Anvil::ServerInstaller::ConfigureDocker < Struct.new(:ssh_connection)
  def call
    script = <<~SCRIPT
      echo "15 0 3 * * /usr/bin/docker system prune -f" | crontab
    SCRIPT
    ssh_connection.exec! script
  end
end
