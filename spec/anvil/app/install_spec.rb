require_relative "../../../lib/anvil/app/install"
RSpec.describe Anvil::App::Install do
  context "when the configuration file lists a single server" do
    let(:configuration) { YAML.load_file(File.dirname(__FILE__) + "/../../fixtures/single-server.config.yml") }
    let(:secrets) { "FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999" }

    it "calls ths HostInstaller for the given server" do
      expect(Anvil::App::HostInstaller).to receive(:new).with(configuration, "server1.example.com", secrets).and_return(double(call: true))
      Anvil::App::Install.new(configuration, secrets).call
    end
  end

  context "when the configuration file lists multiple servers" do
    let(:configuration) { YAML.load_file(File.dirname(__FILE__) + "/../../fixtures/multi-server.config.yml") }
    let(:secrets) { "FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999" }

    it "calls the HostInstaller for each server" do
      expect(Anvil::App::HostInstaller).to receive(:new).with(configuration, "server1.example.com", secrets).and_return(double(call: true))
      expect(Anvil::App::HostInstaller).to receive(:new).with(configuration, "server2.example.com", secrets).and_return(double(call: true))
      Anvil::App::Install.new(configuration, secrets).call
    end
  end
end
