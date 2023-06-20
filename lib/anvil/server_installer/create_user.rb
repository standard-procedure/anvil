# frozen_string_literal: true

class Anvil::ServerInstaller::CreateUser < Struct.new(:ssh_connection, :user_name)
  def call
    script = <<~SCRIPT
      if id -u #{user_name} >/dev/null 2>&1; then
        echo "#{user_name} already exists"
      else
        echo "Adding #{user_name}"
        adduser --disabled-password --gecos "" #{user_name}
        usermod -aG sudo #{user_name}
        usermod -aG docker #{user_name}
        echo "#{user_name} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        fi
    SCRIPT
    ssh_connection.exec! script, "CreateUser"
  end
end
