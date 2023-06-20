# frozen_string_literal: true

require "yaml"
require_relative "server_installer"

# The Installer reads the configuration and runs the ServerInstaller for each host.
class Anvil::Installer < Struct.new(:configuration, :private_key, :passphrase)
  def call
    hosts.each do |host|
      Anvil::ServerInstaller.new(host, configuration, private_key, passphrase).call
    end
  end

  def hosts
    configuration["hosts"]
  end
end
