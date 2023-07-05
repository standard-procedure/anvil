# frozen_string_literal: true

module Anvil
  class App
    require_relative "host_scaler"
    class Scale < Struct.new(:configuration)
      include ConfigurationReader
      def call
        hosts.each do |host|
          HostScaler.new(configuration, host.to_s.strip).call
        end
      end
    end
  end
end
