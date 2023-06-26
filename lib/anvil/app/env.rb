# frozen_string_literal: true

module Anvil
  class App
    class Env < Struct.new(:configuration, :host)
      def call
        puts hosts.inspect
        validate_hosts
        [primary_host_env_vars, app_env_vars, secret_env_vars].compact.join(" ")
      end

      protected

      def hosts
        configuration["hosts"].collect { |host_data| host_data.keys }.flatten
      end

      def validate_hosts
        raise ArgumentError.new("Host #{host} is not in the configuration hosts list") unless hosts.include? host
      end

      def primary_host_env_vars
        return nil unless primary_host?
        generate_from environment_for(host)
      end

      def app_env_vars
        generate_from app_environment
      end

      def secret_env_vars
        generate_from secrets
      end

      def primary_host?
        host == hosts.first
      end

      def generate_from variables
        variables&.join(" ")
      end

      def secrets_file
        configuration["app"]["secrets"]
      end

      def has_secrets?
        !secrets_file.nil? && File.exist?(secrets_file)
      end

      def secrets
        has_secrets? ? nil : YAML.load_file(secrets_file)["secrets"]
      end

      def app_environment
        configuration["app"]["environment"]
      end

      def environment_for hostname
        configuration["hosts"].find { |host_data| host_data.key?(hostname) }&.[]"env"
      end
    end
  end
end
