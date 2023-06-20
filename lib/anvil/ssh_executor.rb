# frozen_string_literal: true

require "net/ssh"

# The Installer reads the configuration and runs the ServerInstaller for each host.
class Anvil::SshExecutor < Struct.new(:hostname, :user, :logger)
  def call &block
    @connection = Net::SSH.start hostname, user, use_agent: true
    block.call self
  end

  def exec! script, category = ""
    @connection.exec! script do |channel, stream, data|
      data.to_s.split("\n") do |line|
        logger.info line, category
      end
    end
  end
end
