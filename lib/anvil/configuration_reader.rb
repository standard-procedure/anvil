# frozen_string_literal: true

module Anvil
  # A set of utility methods for reading configuration data
  # It expects the implemneting class to have a `configuration` method
  module ConfigurationReader
    def hosts
      configuration["hosts"].collect { |host_data| host_data.keys }.flatten
    end

    def validate hostname
      raise ArgumentError.new("Host #{hostname} is not in the configuration hosts list") unless hosts.include? hostname
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
