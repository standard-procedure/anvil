# frozen_string_literal: true

require_relative "subcommand"

module Anvil
  class Mysql < Anvil::SubCommandBase
    require_relative "mysql/create"
    require_relative "mysql/grant"

    desc "create", "Create mysql databases and users "
    subcommand "create", Anvil::Mysql::Create

    desc "grant", "Grant mysql permissions"
    subcommand "grant", Anvil::Mysql::Grant
  end
end
