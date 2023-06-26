# frozen_string_literal: true

require_relative "../../../lib/anvil/app/env"
RSpec.describe Anvil::App::Env do
  context "when the configuration file lists a single server" do
    context "with settings for the app" do
      let(:configuration) { YAML.load_file(File.dirname(__FILE__) + "/../../fixtures/single-server.config.yml") }
      subject { Anvil::App::Env.new(configuration, "server1.example.com") }

      it "generates a string environment variables and values" do
        expect(subject.call).to eq "ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production"
      end
    end

    context "with settings for the app and some secrets" do
      let(:configuration) { YAML.load_file(File.dirname(__FILE__) + "/../../fixtures/single-server-with-secrets.config.yml") }
      subject { Anvil::App::Env.new(configuration, "server1.example.com") }

      it "generates a string environment variables and values" do
        expect(subject.call).to eq "ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999"
      end
    end
  end

  context "when the configuration file lists multiple servers" do
    let(:configuration) { YAML.load_file(File.dirname(__FILE__) + "/../../fixtures/multi-server.config.yml") }

    it "requires a host to be specified" do
      expect { Anvil::App::Env.new(configuration, "").call }.to raise_error(ArgumentError)
    end

    it "generates a string environment variables and values for the primary server" do
      subject = Anvil::App::Env.new(configuration, "server1.example.com")

      expect(subject.call).to eq "PRIMARY=true ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999"
    end

    it "generates a string environment variables and values for the secondary server" do
      subject = Anvil::App::Env.new(configuration, "server2.example.com")

      expect(subject.call).to eq "ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999"
    end
  end
end
