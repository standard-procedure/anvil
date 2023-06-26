# frozen_string_literal: true

module Anvil
  class App
    class Env < Struct.new(:configuration, :host, :secrets)
      def call
        validate_hosts
        [env_vars_for(host), env_vars_for_app, secrets].compact.join(" ")
      end

      protected

      def hosts
        configuration["hosts"].collect { |host_data| host_data.keys }.flatten
      end

      def validate_hosts
        raise ArgumentError.new("Host #{host} is not in the configuration hosts list") unless hosts.include? host
      end

      def env_vars_for host
        generate_from environment_for(host)
      end

      def env_vars_for_app
        generate_from environment_for_app
      end

      def generate_from variables
        variables&.join(" ")
      end

      def environment_for_app
        configuration["app"]["environment"]
      end

      def environment_for hostname
        host_config = configuration["hosts"].find { |host_data| host_data.key?(hostname) ? host_data[hostname] : nil }
        (host_config.nil? || host_config[hostname].nil?) ? nil : host_config[hostname]["env"]
      end
    end
  end
end
