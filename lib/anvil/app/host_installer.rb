# frozen_string_literal: true

require "standard_procedure/async"
module Anvil
  require_relative "../logger"
  require_relative "../ssh_executor"
  require_relative "env"
  class App
    class HostInstaller < Struct.new(:configuration, :host, :secrets)
      include StandardProcedure::Async::Actor

      async :call do
        Anvil::SshExecutor.new(host, user_for(host), logger).call do |ssh|
          create_app ssh
          set_environment ssh
          set_dokku_options ssh
          run_post_installation_scripts ssh
        end
      end

      protected

      def create_app ssh
        ssh.exec! "dokku apps:create app", "create_app"
      end

      def set_environment ssh
        ssh.exec! "dokku config:set app #{Anvil::App::Env.new(configuration, host, secrets).call}", "set_environment"
      end

      def set_dokku_options ssh
        ssh.exec! "dokku docker-options:add app run \"--add-host=host.docker.internal:host-gateway\"", "set_dokku_options"
        ssh.exec! "dokku domains:set app #{configuration_for_app["domain"]}", "set_dokku_options"
        ssh.exec! "dokku proxy:ports-add app http:80:#{configuration_for_app["port"]}", "set_dokku_options"
        ssh.exec! "dokku nginx:set app client-max-body-size 512m", "set_dokku_options"
        ssh.exec! "dokku nginx:set app proxy-read-timeout 60s", "set_dokku_options"
        ssh.exec! "dokku proxy:build-config app", "set_dokku_options"
      end

      def run_post_installation_scripts ssh
        configuration_for_app.fetch("scripts")&.fetch("post_install")&.each do |script|
          ssh.exec! script, "run_post_installation_scripts"
        end
        configuration_for(host).fetch("scripts")&.fetch("post_install")&.each do |script|
          ssh.exec! script, "run_post_installation_scripts"
        end
      end

      def logger
        @logger ||= Anvil::Logger.new("HostInstaller - #{host}")
      end
    end
  end
end
