# frozen_string_literal: true

module Anvil
  class App
    require_relative "host_deployer"
    class Deploy < Struct.new(:configuration)
      include ConfigurationReader
      def call
        branch = `git rev-parse --abbrev-ref HEAD`.strip
        hosts.each do |host|
          HostDeployer.new(configuration, host.to_s.strip, branch).call
        end
      end
    end
  end
end
