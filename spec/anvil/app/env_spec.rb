# frozen_string_literal: true

require_relative "../../../lib/anvil/app/env"
RSpec.describe Anvil::App::Env do
  context "when the configuration file lists a single server" do
    let(:configuration) { YAML.load_file(File.dirname(__FILE__) + "/../../fixtures/single-server.config.yml") }
    let(:secrets) { "FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999" }

    context "with settings for the app" do
      it "generates environment variables for the app" do
        subject = Anvil::App::Env.new(configuration, "server1.example.com")
        expect(subject.call).to eq "ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production"
      end

      it "uses the first server if no host is specified" do
        subject = Anvil::App::Env.new(configuration)
        expect(subject.call).to eq "ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production"
      end

      it "includes any provided secrets" do
        subject = Anvil::App::Env.new(configuration, "server1.example.com", secrets)
        expect(subject.call).to eq "ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999"
      end
    end
  end

  context "when the configuration file lists multiple servers" do
    let(:configuration) { YAML.load_file(File.dirname(__FILE__) + "/../../fixtures/multi-server.config.yml") }
    let(:secrets) { "FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999" }

    it "requires a host to be specified" do
      expect { Anvil::App::Env.new(configuration, "").call }.to raise_error(ArgumentError)
    end

    it "generates environment variables including values for the first server" do
      subject = Anvil::App::Env.new(configuration, "server1.example.com", secrets)

      expect(subject.call).to eq "PRIMARY=true ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999"
    end

    it "generates environment variables including values for the second server" do
      subject = Anvil::App::Env.new(configuration, "server2.example.com", secrets)

      expect(subject.call).to eq "ENV_VAR=value ENV_VAR2=value2 RAILS_ENV=production FIRST_API_KEY=999999ABCDEF SECOND_API_KEY=ABCDEF999999"
    end
  end
end
