require_relative "../ssh_executor"
require_relative "../logger"
require_relative "../script_runner"

module Anvil
  class Mysql
    class DatabaseCreator < Struct.new(:db_name, :user, :host, :mysql_user, :mysql_password, :mysql_host, :mysql_port)
      def call
        ScriptRunner.new(script, user, host, logger).call
      end

      def db_script
        "CREATE DATABASE #{db_name};"
      end

      def script
        "mysql -u#{mysql_user} -p#{mysql_password} -h #{mysql_host} -P #{mysql_port} -e \"#{db_script}\""
      end

      def logger
        Anvil::Logger.new(self.class.name)
      end
    end
  end
end
