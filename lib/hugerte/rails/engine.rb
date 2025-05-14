module HugeRTE::Rails
  class Engine < ::Rails::Engine
    config.hugerte = ActiveSupport::OrderedOptions.new

    # Set an explicit base path for HugeRTE assets (usually defaults to /assets/hugerte)
    config.hugerte.base = nil

    # Set default configuration file path (defaults to config/hugerte.yml within the Rails root if unset)
    config.hugerte.config_path = nil

    # Set default installation method (:compile or :copy) for HugeRTE assets
    #   :compile - adds HugeRTE to the Sprockets load paths and creates non-digested symlinks to the digested versions
    #   :copy    - copies across the HugeRTE assets statically
    config.hugerte.install = :compile

    # Set default attributes for script source tags (defaults to data-turbolinks-track="reload" for backwards compatibility)
    config.hugerte.default_script_attributes = { "data-turbolinks-track" => "reload" }

    initializer "precompile", :group => :all do |app|
      if config.hugerte.install == :compile
        app.config.assets.precompile << "hugerte-rails.manifest.js" # Sprockets 4 manifest
        app.config.assets.precompile << "hugerte/*"                 # Sprockets 3
      end

      app.config.assets.precompile << "hugerte.js" << "hugerte-jquery.js"
    end if defined?(Sprockets)

    initializer "propshaft" do |app|
      config.assets.excluded_paths << root.join("app/assets/sprockets")

      if config.assets.server
        # Monkey-patch Propshaft::Asset to enable access
        # of HugeRTE assets without a hash digest.
        require_relative "propshaft/asset"
      end
    end if defined?(Propshaft)

    initializer "helper" do |app|
      ActiveSupport.on_load(:action_view) do
        include Helper
      end
    end

    def self.base
      config.hugerte.base || default_base
    end

    def self.default_base
      File.join(asset_host || "", relative_url_root || "",
                Rails.application.config.assets.prefix || "/",
                "hugerte")
    end

    def self.relative_url_root
      config = Rails.application.config

      if config.respond_to?(:relative_url_root)
        config.relative_url_root
      else
        # Fallback for Rails 3.1
        config.action_controller.relative_url_root
      end
    end

    def self.asset_host
      host = Rails.application.config.action_controller.asset_host

      if host.respond_to?(:call)
        # Callable asset hosts cannot be supported during
        # precompilation as there is no request object
        nil
      elsif host =~ /%d/
        # Load all HugeRTE assets from the first asset host
        normalize_host(host % 0)
      else
        normalize_host(host)
      end
    end

    def self.normalize_host(host)
      if host =~ /^https?:\/\// || host =~ /^\/\//
        host
      else
        # Use a protocol-relative URL if not otherwise specified
        "//#{host}"
      end
    end

    def self.config_path
      Rails.application.config.hugerte.config_path || ::Rails.root.join("config/hugerte.yml")
    end
  end
end
