# frozen_string_literal: true

require "spec_helper"

require "decidim_app/k8s/manager"
require "decidim_app/k8s/commands/organization"
require "decidim_app/k8s/commands/system_admin"
require "decidim_app/k8s/commands/admin"

describe DecidimApp::K8s::Manager do
  subject { described_class.new("spec/fixtures/k8s_configuration_example.yml") }

  describe "#run" do
    it "runs the installation" do
      expect(DecidimApp::K8s::Commands::SystemAdmin).to receive(:run).once
      expect(DecidimApp::K8s::Commands::Organization).to receive(:run).twice
      expect(DecidimApp::K8s::Commands::Admin).to receive(:run).twice

      subject.run
    end

    context "when configuration is invalid" do
      before do
        allow(YAML).to receive(:load_file).and_return({})
        allow(DecidimApp::K8s::Configuration).to receive(:valid?).and_return(false)
      end

      it "raises runtime error" do
        expect { subject.run }.to raise_error(RuntimeError)
      end
    end
  end

  describe ".run" do
    it "runs the installation" do
      expect(described_class).to receive(:run).once
      described_class.run("spec/fixtures/k8s_configuration_example.yml")
    end
  end
end
