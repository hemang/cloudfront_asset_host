module ActionView
  module Helpers
    module AssetTagHelper

    private

      # Override asset_id so it calculates the key by md5 instead of modified-time
      def rails_asset_id_with_cloudfront(source)
        if @@cache_asset_timestamps && (asset_id = @@asset_timestamps_cache[source])
          asset_id
        else
          asset_id = lookup_asset_id_with_cloudfront(source)

          if @@cache_asset_timestamps
            @@asset_timestamps_cache_guard.synchronize do
              @@asset_timestamps_cache[source] = asset_id
            end
          end

          asset_id
        end
      end

      def lookup_asset_id_with_cloudfront(source)
        path = File.join(ASSETS_DIR, source)
        return '' unless File.exist?(path)

        use_cdn = CloudfrontAssetHost.use_cdn_for_source?(source)
        return CloudfrontAssetHost.key_for_path(path) if use_cdn

        File.mtime(path).to_i.to_s
      end

      # Override asset_path so it prepends the asset_id
      def rewrite_asset_path_with_cloudfront(source)
        asset_id = rails_asset_id(source)
        return source unless asset_id.present?

        use_cdn = CloudfrontAssetHost.use_cdn_for_source?(source)
        use_cdn ? "/#{asset_id}#{source}" : "#{source}?#{asset_id}"
      end
    end
  end
end
