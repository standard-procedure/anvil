# frozen_string_literal: true

require_relative "../subcommand"
module Anvil
  class Mysql
    require_relative "password"
    require_relative "privileges_granter"
    class Grant < Anvil::SubCommandBase
      include Password

      desc "all db_name db_username user host", "Grant all privileges on db_name to db_user"
      option :mysql_user, type: :string, default: "root", aliases: "-m"
      option :mysql_password, type: :string, default: nil, aliases: "-p"
      option :mysql_host, type: :string, default: "localhost", aliases: "-H"
      option :mysql_port, type: :numeric, default: 3306, aliases: "-P"
      def all db_name, db_username, user, host
        password = get_password_from options[:mysql_password]
        Anvil::Mysql::PrivilegesGranter.new(db_name, db_username, user, host, options[:mysql_user], password, options[:mysql_host], options[:mysql_port]).call
      end
    end
  end
end
