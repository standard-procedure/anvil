# frozen_string_literal: true

require "thor"
require_relative "cloudinit"
require_relative "app"

module Anvil
  class Cli < Thor
    desc "cloudinit", "Generate a cloudinit configuration"
    subcommand "cloudinit", Anvil::Cloudinit

    desc "app", "Install or deploy a dokku app"
    subcommand "app", Anvil::App

    desc "version", "Print the version of the anvil gem"
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
end
