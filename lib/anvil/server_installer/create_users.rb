# frozen_string_literal: true

class Anvil::ServerInstaller::CreateUsers < Struct.new(:ssh_connection, :names)
  def call
    names.collect do |name|
      script = <<~SCRIPT
        if id -u #{name} >/dev/null 2>&1; then
          echo "#{name} already exists"
        else
          echo "Adding #{name}"
          adduser --disabled-password --gecos "" #{name}
          usermod -aG sudo #{name}
          usermod -aG docker #{name}
          echo "#{name} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
          fi
      SCRIPT
      ssh_connection.exec! script, "CreateUsers"
    end
  end
end
