# frozen_string_literal: true

class Anvil::ServerInstaller::ConfigureDokku < Struct.new(:ssh_connection, :hostname)
  def call
    script = <<~SCRIPT
      dokku domains:set-global #{hostname}
      dokku git:set --global deploy-branch main
    SCRIPT
    ssh_connection.exec! script, "ConfigureDokku"
  end
end
