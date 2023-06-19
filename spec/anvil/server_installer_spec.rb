# frozen_string_literal: true

require_relative "../../lib/anvil/server_installer"
RSpec.describe Anvil::ServerInstaller do
  subject { Anvil::ServerInstaller.new(host, configuration, key_cert) }

  let(:host) { "server1.example.com" }
  let(:configuration) { YAML.load_file("spec/fixtures/configuration.yml") }
  let(:key_cert) { "spec/fixtures/private_key" }
  let(:ssh_connection) { double "net/ssh" }
  let(:plugins_config) do
    {
      "cron-restart" => {"url" => "https://github.com/dokku/dokku-cron-restart.git"},
      "letsencrypt" => {"url" => "https://github.com/dokku/dokku-letsencrypt.git", "config" => ["set --global email ssl-admin@mycompany.com", "cronjob --add"]}
    }
  end

  it "runs the installation scripts in order" do
    expect(Net::SSH).to receive(:start).with(host, "user", key_certs: [key_cert]).and_yield(ssh_connection)
    expect(Anvil::ServerInstaller::SetHostname).to receive(:new).with(ssh_connection, "server1.example.com").and_return(double(call: true))
    expect(Anvil::ServerInstaller::SetTimezone).to receive(:new).with(ssh_connection, "Europe/London").and_return(double(call: true))
    expect(Anvil::ServerInstaller::InstallPackages).to receive(:new).with(ssh_connection, "spec/fixtures/fake-key.pub").and_return(double(call: true))
    expect(Anvil::ServerInstaller::CreateUsers).to receive(:new).with(ssh_connection, ["first_app", "second_app"]).and_return(double(call: true))
    expect(Anvil::ServerInstaller::ConfigureDokku).to receive(:new).with(ssh_connection, "server1.example.com").and_return(double(call: true))
    expect(Anvil::ServerInstaller::ConfigureDocker).to receive(:new).with(ssh_connection).and_return(double(call: true))
    expect(Anvil::ServerInstaller::InstallPlugins).to receive(:new).with(ssh_connection, plugins_config).and_return(double(call: true))
    expect(Anvil::ServerInstaller::ConfigureFirewall).to receive(:new).with(ssh_connection, ["22/tcp", "80/tcp", "443/tcp"]).and_return(double(call: true))
    expect(Anvil::ServerInstaller::ConfigureSshServer).to receive(:new).with(ssh_connection).and_return(double(call: true))

    subject.call
  end
end
