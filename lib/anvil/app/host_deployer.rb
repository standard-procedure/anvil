# frozen_string_literal: true

require "standard_procedure/async"
module Anvil
  require_relative "../logger"
  require_relative "../ssh_executor"
  require_relative "../configuration_reader"
  class App
    class HostDeployer < Struct.new(:configuration, :host, :branch)
      include StandardProcedure::Async::Actor
      include Anvil::ConfigurationReader

      def call
        first_deployment = !git_remote_exists?
        if first_deployment
          switch_off_downtime_checks
          create_git_remote
        end

        do_git_push
        if first_deployment
          switch_on_downtime_checks
          run_after_first_deployment_scripts
          scale_processes
        else
          run_after_deployment_scripts
        end
        logger.info "Deployment for #{host} complete"
      end

      protected

      def git_remote_exists?
        `git remote show`.split("\n").include? host
      end

      def switch_off_downtime_checks
        Anvil::SshExecutor.new(host, user_for(host), logger).call do |ssh|
          ssh.exec! "dokku checks:disable app worker,web"
        end
      end

      def create_git_remote
        logger.info "git remote add #{host} dokku@#{host}:/app"
        logger.info `git remote add #{host} dokku@#{host}:/app`
      end

      def do_git_push
        logger.info "git push #{host} #{branch}:main"
        logger.info `git push #{host} #{branch}:main`
      end

      def switch_on_downtime_checks
        Anvil::SshExecutor.new(host, user_for(host), logger).call do |ssh|
          ssh.exec! "dokku checks:enable app web"
        end
      end

      def run_after_first_deployment_scripts
        Anvil::SshExecutor.new(host, user_for(host), logger).call do |ssh|
          (configuration_for(host).dig("scripts")&.dig("after_first_deploy") || []).each do |script|
            ssh.exec! script, "run_after_install_scripts"
          end
          (configuration_for_app.dig("scripts")&.dig("after_first_deploy") || []).each do |script|
            ssh.exec! script, "run_after_install_scripts"
          end
        end
      end

      def scale_processes
        Anvil::App::HostScaler.new(configuration, host).call
      end

      def run_after_deployment_scripts
        Anvil::SshExecutor.new(host, user_for(host), logger).call do |ssh|
          (configuration_for(host).dig("scripts")&.dig("after_deploy") || []).each do |script|
            ssh.exec! script, "run_after_install_scripts"
          end
          (configuration_for_app.dig("scripts")&.dig("after_deploy") || []).each do |script|
            ssh.exec! script, "run_after_install_scripts"
          end
        end
      end

      def logger
        @logger ||= Anvil::Logger.new(host)
      end
    end
  end
end
