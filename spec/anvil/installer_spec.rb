# frozen_string_literal: true

require_relative "../../lib/anvil/installer"
RSpec.describe Anvil::Installer do
  subject { Anvil::Installer.new(configuration, private_key, passphrase) }

  let(:configuration) { YAML.load_file("spec/fixtures/configuration.yml") }
  let(:private_key) { "spec/fixtures/private_key" }
  let(:passphrase) { "secret" }

  it "knows which hosts are configured" do
    expect(subject.hosts).to eq %w[server1.example.com server2.example.com]
  end

  it "runs a server installer for each host" do
    expect(Anvil::ServerInstaller).to receive(:new).with("server1.example.com", configuration, private_key, passphrase).and_return(double(call: true))
    expect(Anvil::ServerInstaller).to receive(:new).with("server2.example.com", configuration, private_key, passphrase).and_return(double(call: true))
    subject.call
  end
end
