require 'spec_helper'

module HugeRTE::Rails
  describe Engine do
    describe ".default_base" do
      before(:each) do
        Rails.application.config.assets.prefix = "/assets"
        Rails.application.config.relative_url_root = nil
        Rails.application.config.action_controller.asset_host = nil
      end

      it "generates a default path based on the asset prefix" do
        expect(HugeRTE::Rails::Engine.default_base).to eq "/assets/hugerte"
      end

      it "ignores the asset prefix if missing" do
        Rails.application.config.assets.prefix = nil
        expect(HugeRTE::Rails::Engine.default_base).to eq "/hugerte"
      end

      it "includes the Rails relative_url_root if provided" do
        Rails.application.config.relative_url_root = "/prefix"
        expect(HugeRTE::Rails::Engine.default_base).to eq "/prefix/assets/hugerte"
      end

      it "includes the asset host if it is a string" do
        Rails.application.config.action_controller.asset_host = "http://assets.example.com"
        expect(HugeRTE::Rails::Engine.default_base).to eq "http://assets.example.com/assets/hugerte"
      end

      it "interpolates the asset host if it is a string containing %d" do
        Rails.application.config.action_controller.asset_host = "http://assets%d.example.com"
        expect(HugeRTE::Rails::Engine.default_base).to eq "http://assets0.example.com/assets/hugerte"
      end

      it "does not include the asset host if it is a callable" do
        Rails.application.config.action_controller.asset_host = ->(request) { "http://assets.example.com" }
        expect(HugeRTE::Rails::Engine.default_base).to eq "/assets/hugerte"
      end

      it "uses a protocol relative address if asset host does not include a protocol" do
        Rails.application.config.action_controller.asset_host = "assets.example.com"
        expect(HugeRTE::Rails::Engine.default_base).to eq "//assets.example.com/assets/hugerte"
      end

      it "includes the asset host as is if it is already a protocol relative address" do
        Rails.application.config.action_controller.asset_host = "//assets.example.com"
        expect(HugeRTE::Rails::Engine.default_base).to eq "//assets.example.com/assets/hugerte"
      end

      it "interpolates and uses a protocol relative address if asset host includes %d and no protocol" do
        Rails.application.config.action_controller.asset_host = "assets%d.example.com"
        expect(HugeRTE::Rails::Engine.default_base).to eq "//assets0.example.com/assets/hugerte"
      end
    end
  end
end
