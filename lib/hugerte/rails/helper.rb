require "active_support/core_ext/hash/keys"

module HugeRTE::Rails
  module Helper
    # Initializes HugeRTE on the current page based on the global configuration.
    #
    # Custom options can be set via the options hash, which will be passed to
    # the HugeRTE init function.
    #
    # By default, all textareas with a class of "hugerte" will have the HugeRTE
    # editor applied. The current locale will also be used as the language when
    # HugeRTE language files are available, falling back to English if not
    # available. The :editor_selector and :language options can be used to
    # override these defaults.
    #
    # @example
    #   <%= hugerte(selector: "editorClass", theme: "inlite") %>
    def hugerte(config=:default, options={})
      javascript_tag(nonce: true) do
        unless @_hugerte_configurations_added
          concat hugerte_configurations_javascript
          concat "\n"
          @_hugerte_configurations_added = true
        end

        concat hugerte_javascript(config, options)
      end
    end

    # Returns the JavaScript code required to initialize HugeRTE.
    def hugerte_javascript(config=:default, options={})
      options, config = config, :default if config.is_a?(Hash)
      options = Configuration.new(options)

      "HugeRTERails.initialize('#{config}', #{options.to_javascript});".html_safe
    end

    # Returns the JavaScript code for initializing each configuration defined within hugerte.yml.
    def hugerte_configurations_javascript(options={})
      javascript = []

      HugeRTE::Rails.each_configuration do |name, config|
        config = config.merge(options) if options.present?
        javascript << "HugeRTERails.configuration.#{name} = #{config.to_javascript};".html_safe
      end

      safe_join(javascript, "\n")
    end

    # Returns the HugeRTE configuration object.
    # It should be converted to JavaScript (via #to_javascript) for use within JavaScript.
    def hugerte_configuration(config=:default, options={})
      options, config = config, :default if config.is_a?(Hash)
      options.stringify_keys!

      base_configuration = HugeRTE::Rails.configuration

      if base_configuration.is_a?(MultipleConfiguration)
        base_configuration = base_configuration.fetch(config)
      end

      base_configuration.merge(options)
    end

    # Includes HugeRTE javascript assets via a script tag.
    def hugerte_assets(options=Rails.application.config.hugerte.default_script_attributes)
      if defined?(Sprockets)
        javascript_include_tag("hugerte", options)
      else
        safe_join([
          hugerte_preinit,
          javascript_include_tag("hugerte/hugerte", options),
          javascript_include_tag("hugerte/rails", options)
        ], "\n")
      end
    end

    # Configures where dynamically loaded HugeRTE assets are located and named
    def hugerte_preinit(base=HugeRTE::Rails::Engine.base)
      js = "window.hugerte = window.hugerte || { base: '#{base}', suffix: '' };"
      javascript_tag(js, nonce: true)
    end

    # Allow methods to be called as module functions:
    #  e.g. HugeRTE::Rails.hugerte_javascript
    module_function :hugerte, :hugerte_javascript, :hugerte_configurations_javascript, :hugerte_configuration, :hugerte_preinit
    public :hugerte, :hugerte_javascript, :hugerte_configurations_javascript, :hugerte_configuration, :hugerte_preinit
  end
end
