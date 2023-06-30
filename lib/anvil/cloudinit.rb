# frozen_string_literal: true

require_relative "subcommand"

module Anvil
  class Cloudinit < Anvil::SubCommandBase
    require_relative "cloudinit/generator"

    desc "list", "List cloudinit generators"
    def list
      Dir[File.dirname(__FILE__) + "/../../assets/cloudinit/*.yml"].each do |filename|
        puts File.basename(filename.to_s, ".yml")
      end
    end

    desc "generate configuration", "Generate a cloudinit configuration"
    long_desc <<-DESC
    Generate a cloudinit configuration for a server

    Example:
      anvil cloudinit generate mysql.ubuntu-22 --user dbuser --public_key ~/.ssh/my_key.pub

    DESC
    option :user, type: :string, default: "app", aliases: "-u"
    option :public_key, type: :string, default: "~/.ssh/id_rsa.pub", aliases: "-k"
    def generate configuration
      filename = File.dirname(__FILE__) + "/../../assets/cloudinit/#{configuration}.yml"
      Anvil::Cloudinit::Generator.new(filename, options[:user], options[:public_key]).call
    end
  end
end
