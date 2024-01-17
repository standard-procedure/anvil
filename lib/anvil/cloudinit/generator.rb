# frozen_string_literal: true

module Anvil
  class Cloudinit
    class Generator < Struct.new(:filename, :user, :public_key_path, :hostname)
      def call
        public_key = public_key_path.to_s.gsub("~", Dir.home)

        if File.exist?(public_key)
          puts File.read(filename).gsub("%{USER}", user).gsub("%{HOSTNAME}", hostname).gsub("%{PUBLIC_KEY}", File.read(public_key))
        else
          puts "Cannot find public key file at #{public_key}"
        end
      end
    end
  end
end
