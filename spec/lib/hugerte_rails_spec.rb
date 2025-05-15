require 'spec_helper'

module HugeRTE
  describe Rails do
    describe ".configuration" do
      after(:each) do
        HugeRTE::Rails.configuration = nil
        ::Rails.application.config.hugerte.config_path = nil
      end

      let(:configuration_file) { double(:configuration => configuration) }
      let(:configuration) { double }

      it "loads the hugerte.yml config file" do
        path = ::Rails.root.join("config/hugerte.yml")
        expect(HugeRTE::Rails::ConfigurationFile).to receive(:new).with(path).and_return(configuration_file)
        expect(HugeRTE::Rails.configuration).to eq(configuration)
      end

      it "loads a custom config file if config.hugerte.config is set" do
        path = ::Rails.root.join("config/hugerte-custom.yml")
        ::Rails.application.config.hugerte.config_path = path

        expect(HugeRTE::Rails::ConfigurationFile).to receive(:new).with(path).and_return(configuration_file)
        expect(HugeRTE::Rails.configuration).to eq(configuration)
      end
    end
  end
end
