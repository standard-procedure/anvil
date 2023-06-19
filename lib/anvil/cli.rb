# frozen_string_literal: true

require "thor"
require_relative "installer"
class Anvil::Cli < Thor
  desc "anvil install", "Perform an installation of dokku on a server"
  long_desc <<-DESC
    Perform an installation of dokku on a server in preparation for deploying apps.

      Example:
      `anvil install CONFIG`

      The default CONFIG file is `anvil.yml` in the current directory.

      Options:
      --key_cert, -k: The path to the key certificate file to use when connecting to the server.
  DESC
  option :key_cert, type: :string, default: nil, aliases: "-k"

  def install config = "anvil.yml", key_cert = nil
    Anvil::Installer.new(configuration_from(config), key_cert).call
  end

  protected

  def configuration_from(file_name)
    @configuration ||= YAML.load_file(File.read(file_name))
  end
end
