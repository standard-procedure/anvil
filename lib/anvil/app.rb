# frozen_string_literal: true

require_relative "subcommand"
require "yaml"

module Anvil
  class App < Anvil::SubCommandBase
    require_relative "app/env"
    require_relative "app/install"
    require_relative "app/deploy"
    require_relative "app/scale"

    desc "env /path/to/config.yml", "Generate environment variables for an app"
    long_desc <<-DESC
    List the environment variables for an app (on a given host)

    Normally you never need call this command directly as it is called by the install command.

    Example:
      anvil app env /path/to/config

      If the /path/to/config is not supplied, it defaults to deploy.yml

    DESC
    option :host, type: :string, default: nil, aliases: "-h"
    option :secrets, type: :string, default: nil, aliases: "-s"
    option :secrets_stdin, type: :boolean, default: false, aliases: "-S"
    def env filename = "deploy.yml"
      configuration = YAML.load_file(filename)
      secrets = read_secrets filename: options[:secrets], stdin: options[:secrets_stdin]
      puts Anvil::App::Env.new(configuration, options[:host], secrets).call
    end

    desc "install /path/to/config.yml", "Install an app"
    long_desc <<-DESC
    Install an app on the hosts specified in the configuration.

    This logs in to each host in turn, using the user specified in the configuration file, it initialises the app, using dokku, then sets up the environment variables and other dokku options and finally runs any post-installation scripts.

    In order to SSH in to the server correctly, it expects the private key to be available via your SSH agent. To test this, make sure you can `ssh user@host` without being prompted for a password.

    Example:
      anvil app install /path/to/config
      If the /path/to/config is not supplied, it defaults to deploy.yml

      If --secrets-stdin is specified then additional environment variable values will be read from STDIN, if --secrets=/path/to/secrets is specified then they will be read from the file specified.  This is so you can specify environment variables that you do not want stored in source control.  These should be formatted as "VAR=value VAR2=value2" etc.

      password-manager read my-secrets | anvil app install /path/to/config --secrets-stdin

      Alternatively you can specify secrets as a separate file using the --secrets option.  Again, this should be formatted as "VAR=value VAR2=value2".
    DESC
    option :secrets, type: :string, default: nil, aliases: "-s"
    option :secrets_stdin, type: :boolean, default: false, aliases: "-S"
    def install filename = "deploy.yml"
      configuration = YAML.load_file(filename)
      secrets = read_secrets filename: options[:secrets], stdin: options[:secrets_stdin]
      Anvil::App::Install.new(configuration, secrets).call
    end

    desc "deploy /path/to/config.yml", "Deploy an app"
    long_desc <<-DESC
    Deploy an app on the hosts specified in the configuration.

    First it checks to see if a git remote exists for each host.

    If not, this counts as a first deployment and it creates the git remote

    Then, whether first deployment or not, it does a `git push` of the current branch to main on the remote.

    Finally, if this is the first deployment, it runs the "after_first_deployment" scripts, otherwise it runs the "after_deployment" scripts.
    DESC
    def deploy filename = "deploy.yml"
      configuration = YAML.load_file(filename)
      Anvil::App::Deploy.new(configuration).call
    end

    desc "scale /path/to/config.yml", "Scale an app"
    long_desc <<-DESC
    Scale a previously deployed app, using the scale values from the config file.

    The scale can either be set per host or per app (with host settings taking priority).
    DESC
    def scale filename = "deploy.yml"
      configuration = YAML.load_file(filename)
      Anvil::App::Scale.new(configuration).call
    end

    protected

    def read_secrets(filename: nil, stdin: false)
      return nil if filename.nil? && !stdin
      return $stdin.read if stdin
      File.read(filename) if File.exist?(filename)
    end
  end
end
