# frozen_string_literal: true

class Anvil::ServerInstaller::InstallPackages < Struct.new(:ssh_connection, :public_key_file)
  def call
    public_key = File.read public_key_file
    script = <<~SCRIPT
      mkdir -p /root/.ssh
      echo "#{public_key}" > /root/.ssh/id_rsa.pub
      mkdir -p /etc/skel/.ssh
      cp /root/.ssh/id_rsa.pub /etc/skel/.ssh/authorized_keys

      sudo apt-get update -qq >/dev/null
      sudo apt-get -qq -y --no-install-recommends install apt-transport-https

      wget -nv -O - https://get.docker.com/ | sh

      wget -qO- https://packagecloud.io/dokku/dokku/gpgkey | sudo tee /etc/apt/trusted.gpg.d/dokku.asc
      DISTRO="$(awk -F= '$1=="ID" { print tolower($2) ;}' /etc/os-release)"
      OS_ID="$(awk -F= '$1=="VERSION_CODENAME" { print tolower($2) ;}' /etc/os-release)"
      echo "deb https://packagecloud.io/dokku/dokku/${DISTRO}/ ${OS_ID} main" | sudo tee /etc/apt/sources.list.d/dokku.list
      sudo apt-get update -qq >/dev/null
      sudo apt-get -qq -y install dokku
      sudo dokku plugin:install-dependencies --core

      cat /root/.ssh/id_rsa.pub | dokku ssh-keys:add admin
    SCRIPT

    ssh_connection.exec! script
  end
end
