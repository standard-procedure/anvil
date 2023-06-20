# frozen_string_literal: true

require "net/ssh"

# The SSH executor is responsible for executing scripts on a remote server via SSH.
# It can be used with or without sudo
# - without sudo it runs the scripts as supplied
# - with sudo it creates a script on the remote server, runs it via sudo, and then deletes it
# If supplied, it will also write the output of the script to a logger.
class Anvil::SshExecutor < Struct.new(:hostname, :user, :use_sudo, :logger)
  def call &block
    @connection = Net::SSH.start hostname, user, use_agent: true
    block.call self
  end

  def exec! script, category = ""
    method = use_sudo ? :exec_with_sudo : :exec_without_sudo
    send(method, script, category) do |channel, stream, data|
      data.to_s.split("\n") do |line|
        logger&.info line, category
      end
    end
  end

  protected

  def exec_without_sudo script, category = "", &block
    @connection.exec! script, &block
  end

  def exec_with_sudo script, category = "", &block
    @connection.exec! "cat >> exec.sh << SCRIPT\n#{script}\nSCRIPT", &block
    @connection.exec! "chmod 755 exec.sh", &block
    @connection.exec! "sudo ./exec.sh", &block
    @connection.exec! "rm exec.sh", &block
  end
end
