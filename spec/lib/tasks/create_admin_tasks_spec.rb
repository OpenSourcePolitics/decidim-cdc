# frozen_string_literal: true

require "spec_helper"

describe "rake decidim_app", type: :task do
  describe "create_system_admin" do

    before do
      allow(Decidim::SystemAdminCreator).to receive(:create!).with(ENV).and_return(true)
    end

    it "preloads the Rails environment" do
      expect(task.prerequisites).to include "environment"
    end

    it "invokes the admin creator" do
      expect { task.invoke }.to output("System admin created successfully\n").to_stdout
    end
  end

  describe "create_admin", type: :task do

    before do
      allow(Decidim::AdminCreator).to receive(:create!).with(ENV).and_return(true)
    end

    it "preloads the Rails environment" do
      expect(task.prerequisites).to include "environment"
    end

    it "invokes the admin creator" do
      expect { task.invoke }.to output("Admin created successfully\n").to_stdout
    end
  end
end

