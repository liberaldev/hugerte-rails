require_relative "copy"

module HugeRTE
  module Rails
    class AssetInstaller
      class CopyNoPreserve < Copy
        def copy_assets
          logger.info "Copying assets (without preserving modes) to #{File.join(target, "hugerte")}"
          FileUtils.cp_r(assets, target)
        end
      end
    end
  end
end
