# frozen_string_literal: true

module Anvil
  class App
    require_relative "host_installer"
    require_relative "../configuration_reader"
    class Install < Struct.new(:configuration, :secrets)
      include ConfigurationReader
      def call
        hosts.each do |host|
          HostInstaller.new(configuration, host, secrets).call
        end
      end
    end
  end
end
