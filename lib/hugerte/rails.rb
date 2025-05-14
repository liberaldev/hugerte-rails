module HugeRTE
  module Rails
    require "hugerte/rails/engine"
    require "hugerte/rails/version"
    require "hugerte/rails/configuration"
    require "hugerte/rails/configuration_file"
    require "hugerte/rails/helper"
    require "hugerte/rails/environment" if defined?(Sprockets::Rails::Environment)

    def self.configuration
      @configuration ||= ConfigurationFile.new(Engine.config_path)
      @configuration.respond_to?(:configuration) ? @configuration.configuration : @configuration
    end

    def self.configuration=(configuration)
      @configuration = configuration
    end

    def self.each_configuration(&block)
      if configuration.is_a?(MultipleConfiguration)
        configuration.each(&block)
      else
        yield :default, configuration
      end
    end
  end
end
