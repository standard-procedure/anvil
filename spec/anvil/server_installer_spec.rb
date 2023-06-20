# frozen_string_literal: true

require_relative "../../lib/anvil/server_installer"
RSpec.describe Anvil::ServerInstaller do
  subject { Anvil::ServerInstaller.new(host, configuration, private_key, passphrase) }

  let(:host) { "server1.example.com" }
  let(:configuration) { YAML.load_file("spec/fixtures/configuration.yml") }
  let(:private_key) { "spec/fixtures/private_key" }
  let(:passphrase) { "secret" }
  let(:plugins_config) do
    {
      "cron-restart" => {"url" => "https://github.com/dokku/dokku-cron-restart.git"},
      "letsencrypt" => {"url" => "https://github.com/dokku/dokku-letsencrypt.git", "config" => ["set --global email ssl-admin@mycompany.com", "cronjob --add"]}
    }
  end

  it "runs the installation scripts in order" do
    logger = double "logger", info: true
    allow(subject).to receive(:logger).and_return(logger)

    ssh_executor = double "Anvil::SshExecutor", exec!: true
    allow(ssh_executor).to receive(:call).and_yield(ssh_executor)

    expect(Anvil::SshExecutor).to receive(:new).with(host, "root", logger).and_return(ssh_executor)

    expect(Anvil::ServerInstaller::SetHostname).to receive(:new).with(ssh_executor, "server1.example.com").and_return(double(call: true))
    expect(Anvil::ServerInstaller::SetTimezone).to receive(:new).with(ssh_executor, "Europe/London").and_return(double(call: true))
    expect(Anvil::ServerInstaller::InstallPackages).to receive(:new).with(ssh_executor, "spec/fixtures/fake-key.pub").and_return(double(call: true))
    expect(Anvil::ServerInstaller::CreateUser).to receive(:new).with(ssh_executor, "user").and_return(double(call: true))
    expect(Anvil::ServerInstaller::ConfigureDokku).to receive(:new).with(ssh_executor, "server1.example.com").and_return(double(call: true))
    expect(Anvil::ServerInstaller::ConfigureDocker).to receive(:new).with(ssh_executor).and_return(double(call: true))
    expect(Anvil::ServerInstaller::InstallPlugins).to receive(:new).with(ssh_executor, plugins_config).and_return(double(call: true))
    expect(Anvil::ServerInstaller::ConfigureFirewall).to receive(:new).with(ssh_executor, ["22/tcp", "80/tcp", "443/tcp"]).and_return(double(call: true))
    expect(Anvil::ServerInstaller::ConfigureSshServer).to receive(:new).with(ssh_executor).and_return(double(call: true))

    subject.call
  end
end
