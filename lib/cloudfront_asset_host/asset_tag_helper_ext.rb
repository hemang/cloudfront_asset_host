module ActionView
  module Helpers
    module AssetTagHelper

    private

      # Override asset_id so it calculates the key by md5 instead of modified-time
      def rails_asset_id_with_cloudfront(source)
        if @@cache_asset_timestamps && (asset_id = @@asset_timestamps_cache[source])
          asset_id
        else
          path = File.join(ASSETS_DIR, source)
          rewrite_path = File.exist?(path) && CloudfrontAssetHost.use_cdn_for_source?(source)
          asset_id = rewrite_path ? CloudfrontAssetHost.key_for_path(path) : rails_asset_id_without_cloudfront(source)

          if @@cache_asset_timestamps
            @@asset_timestamps_cache_guard.synchronize do
              @@asset_timestamps_cache[source] = asset_id
            end
          end

          asset_id
        end
      end

      # Override asset_path so it prepends the asset_id
      def rewrite_asset_path_with_cloudfront(source)
        if CloudfrontAssetHost.use_cdn_for_source?(source)
          asset_id = rails_asset_id(source)
          "/#{asset_id}#{source}"
        else
          rewrite_asset_path_without_cloudfront(source)
        end
      end

    end
  end
end
