# frozen_string_literal: true

require_relative "../subcommand"
require "rujitsu"
module Anvil
  class Mysql
    require_relative "password"
    require_relative "database_creator"
    require_relative "user_creator"

    class Create < Anvil::SubCommandBase
      include Password

      desc "database db_name user host", "Create a mysql database"
      long_desc <<-DESC
        Create a mysql database by SSHing into a server and then connecting to MySQL to create the database.

        Example:

          anvil mysql create database my_database user server.example.com --mysql-user root --mysql-host data.internal.example.com

        This command will SSH into user@server.example.com, then connect to the MySQL server on data.internal.example.com as root to create the database.  It will take the root password from STDIN.

        The assumption is that your MySQL server is not accessible from your local development machine.

        The SSH command assumes you have a current SSH Agent to load your private key.

        You can optionally supply a password for the MySQL user, or it will be read from STDIN.
      DESC
      option :mysql_user, type: :string, default: "root", aliases: "-m"
      option :mysql_password, type: :string, default: nil, aliases: "-p"
      option :mysql_host, type: :string, default: "localhost", aliases: "-H"
      option :mysql_port, type: :numeric, default: 3306, aliases: "-P"
      def database db_name, user, host
        password = get_password_from options[:mysql_password]
        Anvil::Mysql::DatabaseCreator.new(db_name, user, host, options[:mysql_user], password, options[:mysql_host], options[:mysql_port]).call
      end

      desc "user db_username user host", "Create a mysql user"
      long_desc <<-DESC
        Create a database user by SSHing into a server and then connecting to MySQL to create the user.

        You can optionally specify a password for your database user, or it will be generated for you and returned to STDOUT.

        Example:

          anvil mysql create user my_user user server.example.com --mysql-user root --mysql-host data.internal.example.com

        This command will SSH into user@server.example.com, then connect to the MySQL server on data.internal.example.com as root to create the user.  It will take the root password from STDIN.

        The assumption is that your MySQL server is not accessible from your local development machine.

        The SSH command assumes you have a current SSH Agent to load your private key.

        You can optionally supply a password for the MySQL user, or it will be read from STDIN.
      DESC
      option :db_password, type: :string, default: nil, aliases: "-d"
      option :mysql_user, type: :string, default: "root", aliases: "-m"
      option :mysql_password, type: :string, default: nil, aliases: "-p"
      option :mysql_host, type: :string, default: "localhost", aliases: "-H"
      option :mysql_port, type: :numeric, default: 3306, aliases: "-P"
      def user db_user, user, host
        mysql_password = options[:mysql_password] || $stdin.gets.chomp
        db_password = options[:db_password] || "#{4.random_letters}-#{4.random_characters}-#{4.random_numbers}-#{4.random_letters}-#{4.random_characters}"
        Anvil::Mysql::UserCreator.new(db_user, db_password, user, host, options[:mysql_user], mysql_password, options[:mysql_host], options[:mysql_port]).call
        puts db_password if options[:db_password].nil?
      end
    end
  end
end
