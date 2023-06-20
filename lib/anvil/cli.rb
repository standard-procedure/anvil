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
      --private_key, -k: The path to the key certificate file to use when connecting to the server.
      --passphrase, -p: The passphrase to use when connecting to the server.
  DESC
  option :private_key, type: :string, default: nil, aliases: "-k"
  option :passphrase, type: :string, default: nil, aliases: "-p"
  def install config = "anvil.yml", private_key = nil, passphrase = nil
    Anvil::Installer.new(configuration_from(config), private_key, passphrase).call
  end

  desc "anvil deploy", "Deploy the current app"
  long_desc <<-DESC
    Deploy the current app to the server to the servers

      Example:
      `anvil deploy CONFIG`

      The default CONFIG file is `anvil.yml` in the current directory.
      Options:
      --private_key, -k: The path to the key certificate file to use when connecting to the server.
      --passphrase, -p: The passphrase to use when connecting to the server.
  DESC
  option :private_key, type: :string, default: nil, aliases: "-k"
  option :passphrase, type: :string, default: nil, aliases: "-p"
  def deploy config = "anvil.yml", private_key = nil, passphrase = nil
  end

  desc "anvil version", "Print the version of the anvil gem"
  def version
    puts Anvil::VERSION
  end

  def self.exit_on_failure?
    true
  end

  protected

  def configuration_from(file_name)
    @configuration ||= YAML.load_file(file_name)
  end
end
