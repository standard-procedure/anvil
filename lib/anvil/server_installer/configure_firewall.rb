# frozen_string_literal: true

class Anvil::ServerInstaller::ConfigureFirewall < Struct.new(:ssh_connection, :ports)
  def call
    ports.collect do |port|
      ssh_connection.exec! "ufw allow #{port}", "ConfigureFirewall"
    end
    ssh_connection.exec! "ufw --force enable", "ConfigureFirewall"
  end
end
