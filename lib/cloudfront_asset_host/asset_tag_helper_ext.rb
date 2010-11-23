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
          if file_exists = File.exist?(path)
            use_cdn = CloudfrontAssetHost.use_cdn_for_source?(source)
            asset_id = if use_cdn
              CloudfrontAssetHost.key_for_path(path)
            else
              File.exist?(path) ? File.mtime(path).to_i.to_s : ''
            end
          else
            asset_id = ''
          end

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
        asset_id = rails_asset_id(source)
        if CloudfrontAssetHost.use_cdn_for_source?(source)
          asset_id.present? ? "/#{asset_id}#{source}" : source
        else
          asset_id.present? ? "#{source}?#{asset_id}" : source
        end
      end

    end
  end
end
