# frozen_string_literal: true

require "net/ssh"

# The SSH executor is responsible for executing scripts on a remote server via SSH.
# It can be used with or without sudo
# - without sudo it runs the scripts as supplied
# - with sudo it creates a script on the remote server, runs it via sudo, and then deletes it
# If supplied, it will also write the output of the script to a logger.
module Anvil
  class SshExecutor < Struct.new(:hostname, :user, :logger)
    def call &block
      @connection = Net::SSH.start hostname, user, use_agent: true
      block.call self
    end

    def exec! script, category = ""
      @connection.exec! script do |channel, stream, data|
        data.to_s.split("\n") do |line|
          logger&.info line, category
        end
      end
    end
  end
end
