# frozen_string_literal: true

require "standard_procedure/async"
module Anvil
  require_relative "../logger"
  require_relative "../ssh_executor"
  require_relative "env"
  require_relative "../configuration_reader"
  class App
    class HostInstaller < Struct.new(:configuration, :host, :secrets)
      include StandardProcedure::Async::Actor
      include Anvil::ConfigurationReader

      def call
        Anvil::SshExecutor.new(host, user_for(host), logger).call do |ssh|
          install_plugins ssh
          create_app ssh
          set_environment ssh
          set_dokku_options ssh
          run_after_install_scripts ssh
        end
      end

      protected

      def install_plugins ssh
        (configuration_for_app.dig("plugins") || []).each do |plugin|
          ssh.exec! "sudo dokku plugin:install https://github.com/dokku/dokku-#{plugin}.git #{plugin}"
        end
      end

      def create_app ssh
        ssh.exec! "dokku apps:create app", "create_app"
      end

      def set_environment ssh
        ssh.exec! "dokku config:set app #{Anvil::App::Env.new(configuration, host, secrets).call}", "set_environment"
      end

      def set_dokku_options ssh
        ssh.exec! "dokku docker-options:add app run \"--add-host=host.docker.internal:host-gateway\"", "set_dokku_options"
        ssh.exec! "dokku domains:set app #{configuration_for_app["domain"]}", "set_dokku_options"
        ssh.exec! "dokku proxy:set app nginx", "set_dokku_options"
        ssh.exec! "dokku ports:add app http:80:#{configuration_for_app["port"]}", "set_dokku_options"
        ssh.exec! "dokku ports:add app https:443:#{configuration_for_app["port"]}", "set_dokku_options"
        ssh.exec! "dokku nginx:set app client-max-body-size #{configuration_for_app["nginx"]["client_max_body_size"]}", "set_dokku_options"
        ssh.exec! "dokku nginx:set app proxy-read-timeout #{configuration_for_app["nginx"]["proxy_read_timeout"]}", "set_dokku_options"
        if configuration_for_app["load_balancer"]
          ssh.exec! "dokku nginx:set app x-forwarded-for-value '$http_x_forwarded_for'", "set_dokku_options"
          ssh.exec! "dokku nginx:set app x-forwarded-port-value '$http_x_forwarded_port'", "set_dokku_options"
          ssh.exec! "dokku nginx:set app x-forwarded-proto-value '$http_x_forwarded_proto'", "set_dokku_options"
        end
        ssh.exec! "dokku proxy:build-config app", "set_dokku_options"
      end

      def run_after_install_scripts ssh
        (configuration_for(host).dig("scripts")&.dig("after_install") || []).each do |script|
          ssh.exec! script, "run_after_install_scripts"
        end
        (configuration_for_app.dig("scripts")&.dig("after_install") || []).each do |script|
          ssh.exec! script, "run_after_install_scripts"
        end
      end

      def logger
        @logger ||= Anvil::Logger.new(host)
      end
    end
  end
end
