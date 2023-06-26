# frozen_string_literal: true

require_relative "subcommand"
require "yaml"

module Anvil
  class App < Anvil::SubCommandBase
    require_relative "app/env"

    desc "env", "Generate environment variables for an app"
    long_desc <<-DESC
    List the environment variables for an app (on a given host)

    Example:
      anvil app env /path/to/config

      If the /path/to/config is not supplied, it defaults to deploy.yml

      Options:

      --host, -h: The server that the environment variables should be generated for - only required if multiple servers are configured

      --secrets, -s: The path to a file containing secrets to be injected into the environment variables

      --secrets-stdin, -S: Read secrets from STDIN instead of a file
    DESC
    option :host, type: :string, default: nil, aliases: "-h"
    option :secrets, type: :string, default: nil, aliases: "-s"
    option :secrets_stdin, type: :boolean, default: false, aliases: "-S"
    def env filename = "deploy.yml"
      configuration = YAML.load_file(filename)
      secrets = read_secrets filename: options[:secrets], stdin: options[:secrets_stdin]
      puts Anvil::App::Env.new(configuration, options[:host], secrets).call
    end

    desc "install", "Install an app"
    long_desc <<-DESC
    Install an app on the hosts specified in the configuration.

    This logs in to each host in turn, using the user specified in the configuration file, it initialises the app, using dokku, then sets up the environment variables and other dokku options and finally runs any post-installation scripts.

    In order to SSH in to the server correctly, it expects the private key to be available via your SSH agent. To test this, make sure you can `ssh user@host` without being prompted for a password.

    Example:
      anvil app install /path/to/config
      If the /path/to/config is not supplied, it defaults to deploy.yml

      Options:

      --secrets, -s: The path to a file containing secrets to be injected into the environment variables

      --secrets-stdin, -S: Read secrets from STDIN instead of a file
    DESC
    def install filename = "deploy.yml"
      configuration = YAML.load_file(filename)
      secrets = read_secrets filename: options[:secrets], stdin: options[:secrets_stdin]
      Anvil::App::Install.new(configuration, secrets).call
    end

    protected

    def read_secrets(filename: nil, stdin: false)
      return nil if filename.nil? && !stdin
      return $stdin.read if stdin
      return File.read(filename) if File.exist?(filename)
    end
  end
end
