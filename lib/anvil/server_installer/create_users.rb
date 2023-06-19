# frozen_string_literal: true

class Anvil::ServerInstaller::CreateUsers < Struct.new(:ssh_connection, :names)
  def call
    names.collect do |name|
      script = <<~SCRIPT
        adduser --disabled-password --gecos "" #{name}
        usermod -aG sudo #{name}
        usermod -aG docker #{name}
        echo "#{name} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
      SCRIPT
      ssh_connection.exec! script
    end
  end
end
