# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_app", type: :task do
  describe "create_system_admin" do

    let!(:task_name) { "decidim_app:create_system_admin" }

    before do
      allow(Decidim::SystemAdminCreator).to receive(:create!).with(ENV).and_return(true)
    end

    it "preloads the Rails environment" do
      expect(Rake::Task[task_name].prerequisites).to include "environment"
    end

    it "invokes the admin creator" do
      expect { Rake::Task[task_name].invoke }.to output("System admin created successfully\n").to_stdout
    end
  end

  describe "create_admin", type: :task do

    let!(:task_name) { "decidim_app:create_admin" }

    before do
      allow(Decidim::AdminCreator).to receive(:create!).with(ENV).and_return(true)
    end

    it "preloads the Rails environment" do
      expect(Rake::Task[task_name].prerequisites).to include "environment"
    end

    it "invokes the admin creator" do
      expect { Rake::Task[task_name].invoke }.to output("Admin created successfully\n").to_stdout
    end
  end
end

