# frozen_string_literal: true

require_relative "../../lib/anvil/ssh_executor"
RSpec.describe Anvil::SshExecutor do
  subject { Anvil::SshExecutor.new("server1.example.com", "user", logger) }
  let(:logger) { double "logger", info: true }
  let(:ssh_connection) { double "net/ssh" }

  before do
    expect(Net::SSH).to receive(:start).with("server1.example.com", "user", use_agent: true).and_return(ssh_connection)
  end

  it "creates an SSH connection and yields to the caller" do
    subject.call do |executor|
      expect(executor).to be_a(Anvil::SshExecutor)
    end
  end

  it "executes the given script and writes single lines to the logger" do
    expect(ssh_connection).to receive(:exec!).with("script").and_yield(nil, nil, "line1\n")
    expect(logger).to receive(:info).with("line1", "category")

    subject.call do |executor|
      executor.exec! "script", "category"
    end
  end

  it "executes the given script and writes multiple lines to the logger" do
    expect(ssh_connection).to receive(:exec!).with("script").and_yield(nil, nil, "line1\nline2\n")
    expect(logger).to receive(:info).with("line1", "category")
    expect(logger).to receive(:info).with("line2", "category")

    subject.call do |executor|
      executor.exec! "script", "category"
    end
  end
end
