require "hugerte/rails/asset_manifest"

module HugeRTE
  module Rails
    describe YamlManifest do
      subject(:manifest) { YamlManifest.new(fixture("yaml_manifest/manifest.yml")) }

      def reload_manifest(manifest)
        YAML.load(manifest.to_s)
      end

      it "keeps existing manifest data" do
        result = reload_manifest(manifest)
        expect(result["application.js"]).to eq("application-d41d8cd98f00b204e9800998ecf8427e.js")
      end

      describe "#append" do
        it "adds files to the manifest without a fingerprint" do
          manifest.append("hugerte/huge_rte_jquery.js", double)

          result = reload_manifest(manifest)
          expect(result["hugerte/huge_rte_jquery.js"]).to eq("hugerte/huge_rte_jquery.js")
        end
      end

      describe "#remove" do
        it "removes files from the manifest" do
          manifest.remove("hugerte.js")

          result = reload_manifest(manifest)
          expect(result).to_not have_key("hugerte.js")
        end
      end

      describe "#remove_digest" do
        it "sets the file digest value to its non-digested version" do
          manifest.remove_digest("hugerte.js")

          result = reload_manifest(manifest)
          expect(result["hugerte.js"]).to eq("hugerte.js")
        end

        it "yields the digested and non-digested file names" do
          expect { |block|
            manifest.remove_digest("hugerte.js", &block)
          }.to yield_with_args("hugerte-025f3a2beeeb18ce2b5f2dafdb14eb86.js", "hugerte.js")
        end
      end

      describe "#each" do
        it "yields the logical path for each asset that matches the given pattern" do
          result = []
          manifest.each(/^hugerte\//) { |asset| result << asset }
          expect(result).to eq ["hugerte/huge_rte.js"]
        end
      end

      describe ".try" do
        it "returns a new YamlManifest if a YAML manifest exists for the given path" do
          manifest = YamlManifest.try(fixture("yaml_manifest"))
          expect(manifest).to be_an_instance_of(YamlManifest)
        end

        it "returns nil if no YAML manifest was found" do
          expect(YamlManifest.try(fixture("no_manifest"))).to be_nil
        end
      end
    end
  end
end
