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
      secrets = if !options[:secrets].nil?
        File.read(options[:secrets])
      elsif options[:secrets_stdin]
        $stdin.read
      end
      puts Anvil::App::Env.new(configuration, options[:host], secrets).call
    end
  end
end
