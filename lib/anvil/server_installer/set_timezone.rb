# frozen_string_literal: true

class Anvil::ServerInstaller::SetTimezone < Struct.new(:ssh_connection, :timezone)
  def call
    script = <<-SCRIPT
    timedatectl set-timezone #{timezone}
    SCRIPT
    ssh_connection.exec! script
  end
end
