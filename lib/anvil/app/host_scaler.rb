# frozen_string_literal: true

require "standard_procedure/async"
module Anvil
  require_relative "../logger"
  require_relative "../ssh_executor"
  require_relative "../configuration_reader"
  class App
    class HostScaler < Struct.new(:configuration, :host)
      include StandardProcedure::Async::Actor
      include Anvil::ConfigurationReader

      def call
        scale_processes
      end

      protected

      def scale_processes
        scale = configuration_for(host).dig("scale") || configuration_for_app.dig("scale") || "web=1"
        Anvil::SshExecutor.new(host, user_for(host), logger).call do |ssh|
          ssh.exec! "dokku ps:scale app #{scale}"
        end
      end

      def logger
        @logger ||= Anvil::Logger.new(host)
      end
    end
  end
end
