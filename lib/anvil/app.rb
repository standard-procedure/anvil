# frozen_string_literal: true

require_relative "subcommand"
require "yaml"

module Anvil
  class App < Anvil::SubCommandBase
    require_relative "app/env"

    desc "env", "Generate environment variables for an app"
    long_desc <<-DESC
    Generate environment variables for an app

    Example:
      anvil app env /path/to/config --host server1.example.com --user app_user

      Options:
      --host, -h: The server that the environment variables should be generated for - only required if multiple servers are configured
      --user, -u: The user to SSH in to each host as - defaults to app. This also requires that your SSH agent is initialised and can handle authentication with the server
    DESC
    option :host, type: :string, default: nil, aliases: "-h"
    option :user, type: :string, default: "app", aliases: "-u"
    def env filename
      configuration = YAML.load_file(filename)
      Anvil::App::Env.new(configuration, options[:host]).call
    end
  end
end
