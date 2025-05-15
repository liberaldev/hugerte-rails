require "hugerte/rails/asset_installer"

module HugeRTE
  module Rails
    describe AssetInstaller do
      let(:assets) { Pathname.new(File.expand_path(File.dirname(__FILE__) + "/../../vendor/assets/javascripts/hugerte")) }
      let(:target) { "/assets" }
      let(:manifest_path) { nil }
      let(:manifest) { double.as_null_object }

      let(:installer) do
        AssetInstaller.new(assets, target, manifest_path).tap do |installer|
          installer.strategy = strategy
          installer.log_level = :warn
        end
      end

      def install
        installer.install
      end

      before(:each) do
        stub_const("HugeRTE::Rails::AssetManifest", double(:load => manifest))
      end

      describe "compile strategy" do
        let(:strategy) { :compile }

        before(:each) do
          allow(FileUtils).to receive(:ln_s)
        end

        it "symlinks non-digested asset paths" do
          digested_asset = "hugerte/langs/es-abcde1234567890.js"
          asset = "hugerte/langs/ko_KR.js"

          allow(manifest).to receive(:each).and_yield(asset)
          expect(manifest).to receive(:asset_path).with(asset).and_yield(digested_asset, asset)

          allow(File).to receive(:exist?).and_return(true)

          expect(FileUtils).to receive(:ln_s).with("es-abcde1234567890.js", "/assets/hugerte/langs/ko_KR.js", :force => true)

          install
        end
      end

      shared_examples_for "copy strategies" do
        before(:each) do
          allow(FileUtils).to receive(:cp_r)
          allow(FileUtils).to receive(:mv)
          allow(FileUtils).to receive(:rm)
        end

        it "removes digests from existing HugeRTE assets in the manifest" do
          digested_asset = "hugerte/langs/es-abcde1234567890.js"
          asset = "hugerte/langs/ko_KR.js"

          allow(manifest).to receive(:each).and_yield(asset)
          expect(manifest).to receive(:remove_digest).with(asset).and_yield(digested_asset, asset)
          allow(File).to receive(:exist?).and_return(true)
          expect(FileUtils).to receive(:mv).with("/assets/hugerte/langs/es-abcde1234567890.js", "/assets/hugerte/langs/ko_KR.js", :force => true)

          install
        end

        it "adds HugeRTE assets to the manifest" do
          expect(manifest).to receive(:append).with("hugerte/hugerte.js", assets.parent.join("hugerte/hugerte.js"))
          expect(manifest).to receive(:append).with("hugerte/themes/silver/theme.js", assets.parent.join("hugerte/themes/silver/theme.js"))
          install
        end

        it "writes the manifest" do
          expect(manifest).to receive(:write)
          install
        end
      end

      describe "copy strategy" do
        let(:strategy) { :copy }

        it_behaves_like "copy strategies"

        it "copies HugeRTE assets to the target directory" do
          expect(FileUtils).to receive(:cp_r).with(assets, target, :preserve => true)
          install
        end
      end

      describe "copy_no_preserve strategy" do
        let(:strategy) { :copy_no_preserve }

        it_behaves_like "copy strategies"

        it "copies HugeRTE assets to the target directory without preserving file modes" do
          expect(FileUtils).to receive(:cp_r).with(assets, target)
          install
        end
      end
    end
  end
end
