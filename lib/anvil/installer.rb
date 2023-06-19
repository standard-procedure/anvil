# frozen_string_literal: true

require "yaml"
require_relative "server_installer"

# The Installer reads the configuration and runs the ServerInstaller for each host.
class Anvil::Installer < Struct.new(:configuration, :key_cert)
  def call
    hosts.each do |host|
      Anvil::ServerInstaller.new(host, configuration, key_cert).call
    end
  end

  def hosts
    configuration["hosts"]
  end
end
