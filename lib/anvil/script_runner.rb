require_relative "ssh_executor"
module Anvil
  class Mysql
    class ScriptRunner < Struct.new(:script, :user, :host, :logger)
      def call
        SshExecutor.new(host, user, logger).call do |ssh|
          ssh.exec! script, "SSH"
        end
      end
    end
  end
end
