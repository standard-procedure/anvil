# frozen_string_literal: true

module Anvil
  class App
    require_relative "../configuration_reader"
    class Env < Struct.new(:configuration, :host, :secrets)
      include ConfigurationReader

      def call
        self.host ||= hosts.first
        validate host
        [env_vars_for(host), env_vars_for_app, secrets].compact.join(" ")
      end

      protected

      def env_vars_for host
        generate_from environment_for(host)
      end

      def env_vars_for_app
        generate_from environment_for_app
      end

      def generate_from variables
        variables&.join(" ")
      end
    end
  end
end
