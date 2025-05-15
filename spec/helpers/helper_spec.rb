require 'spec_helper'

module HugeRTE::Rails
  describe Helper do
    if defined?(Sprockets)
      include Sprockets::Rails::Helper

      app, config = Rails.application, Rails.application.config

      self.debug_assets      = config.assets.debug
      self.digest_assets     = config.assets.digest
      self.assets_prefix     = config.assets.prefix
      self.assets_precompile = config.assets.precompile

      self.assets_environment = app.assets
      self.assets_manifest    = app.assets_manifest

      self.resolve_assets_with = [:environment] if respond_to?(:resolve_assets_with=)
    elsif defined?(Propshaft)
      include Propshaft::Helper
    end

    let(:content_security_policy_nonce) { "nonce" }

    describe "#hugerte_assets" do
      context "using Sprockets", if: defined?(Sprockets) do
        it "returns a bundled HugeRTE javascript tag" do
          script = hugerte_assets
          expect(script).to have_selector("script[src='#{asset_path("hugerte.js")}'][data-turbolinks-track='reload']", visible: false)
        end

        it "allows custom attributes to be set on the script tag" do
          script = hugerte_assets(defer: true, data: { turbo_track: "reload" })
          expect(script).to have_selector("script[src='#{asset_path("hugerte.js")}'][defer][data-turbo-track='reload']", visible: false)
        end
      end

      context "using Propshaft", if: defined?(Propshaft) do
        it "returns HugeRTE preinit code and separate javascript asset tags" do
          result = hugerte_assets
          expect(result).to include(hugerte_preinit)
          expect(result).to have_selector("script[src='#{asset_path("hugerte/hugerte.js")}'][data-turbolinks-track='reload']", visible: false)
          expect(result).to have_selector("script[src='#{asset_path("hugerte/rails.js")}'][data-turbolinks-track='reload']", visible: false)
        end

        it "allows custom attributes to be set on the script tags" do
          result = hugerte_assets(defer: true, data: { turbo_track: "reload" })
          expect(result).to include(hugerte_preinit)
          expect(result).to have_selector("script[src='#{asset_path("hugerte/hugerte.js")}'][defer][data-turbo-track='reload']", visible: false)
          expect(result).to have_selector("script[src='#{asset_path("hugerte/rails.js")}'][defer][data-turbo-track='reload']", visible: false)
        end
      end
    end

    describe "#hugerte" do
      before(:each) do
        allow(HugeRTE::Rails).to receive(:configuration).and_return(configuration)
      end

      context "single-configuration" do
        let(:configuration) {
          Configuration.new("theme" => "advanced", "plugins" => %w(paste table fullscreen))
        }

        it "initializes HugeRTE using global configuration" do
          result = hugerte
          expect(result).to have_selector("script", visible: false)
          expect(result).to include('HugeRTERails.configuration.default = {')
          expect(result).to include('theme: "advanced"')
          expect(result).to include('plugins: "paste,table,fullscreen"')
          expect(result).to include('};')
        end

        it "initializes HugeRTE with passed in options" do
          result = hugerte(:theme => "simple")
          expect(result).to include('theme: "simple"')
          expect(result).to include('plugins: "paste,table,fullscreen"')
        end

        it "outputs function strings without quotes" do
          result = hugerte(:oninit => "function() { alert('Hello'); }")
          expect(result).to include('oninit: function() { alert(\'Hello\'); }')
        end

        it "outputs nested function strings without quotes" do
          result = hugerte(:nested => { :oninit => "function() { alert('Hello'); }" })
          expect(result).to include('oninit: function() { alert(\'Hello\'); }')
        end
      end

      context "multiple-configuration" do
        let(:configuration) {
          MultipleConfiguration.new(
            "default" => { "theme" => "advanced", "plugins" => %w(paste table) },
            "alternate" => { "skin" => "alternate" }
          )
        }

        it "initializes HugeRTE with default configuration" do
          result = hugerte
          expect(result).to include('theme: "advanced"')
          expect(result).to include('plugins: "paste,table"')
        end

        it "merges passed in options with default configuration" do
          result = hugerte(:theme => "simple")
          expect(result).to include('theme: "simple"')
          expect(result).to include('plugins: "paste,table"')
        end

        it "initializes HugeRTE with custom configuration" do
          result = hugerte(:alternate)
          expect(result).to include('skin: "alternate"')
        end

        it "merges passed in options with custom configuration" do
          result = hugerte(:alternate, :theme => "simple")
          expect(result).to include('theme: "simple"')
          expect(result).to include('skin: "alternate"')
        end
      end
    end

    describe "#hugerte_preinit" do
      it "returns HugeRTE preinit script" do
        result = hugerte_preinit
        expect(result).to have_selector("script", visible: false)
        expect(result).to include("window.hugerte = window.hugerte || { base: '/assets/hugerte', suffix: '' };")
      end
    end
  end
end
