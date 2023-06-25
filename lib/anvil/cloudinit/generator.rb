# frozen_string_literal: true

module Anvil
  class Cloudinit
    class Generator < Struct.new(:filename, :user, :public_key_path)
      def call
        public_key = public_key_path.to_s.gsub("~", Dir.home)

        if File.exist?(public_key)
          puts File.read(filename).gsub("%{USER}", user).gsub("%{PUBLIC_KEY}", File.read(public_key))
        else
          puts "Cannot find public key file at #{public_key}"
        end
      end
    end
  end
end

# Compare this snippet from assets/cloudinit/mysql.ubuntu-22.yml:
# # frozen_string_literal: true
#
# ---
# packages:
#   - mysql-server
#   - mysql-client
#   - libmysqlclient-dev
#
# users:
#   - name: <%= user %>
#     groups: sudo
#     shell: /bin/bash
#     sudo: ALL=(ALL) NOPASSWD:ALL
#     ssh_authorized_keys:
#       - <%= public_key %>
#
# files:
#   - path: /etc/mysql/mysql.conf.d/mysqld.cnf
#     content: |
#       [mysqld]
#       bind-address =
