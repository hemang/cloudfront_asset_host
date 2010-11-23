require 'test_helper'
require 'action_view/test_case'

class CloudfrontAssetTagHelperTest < ActionView::TestCase
  tests ActionView::Helpers::AssetTagHelper

  context "with enabled CDN" do
    setup do
      CloudfrontAssetHost.configure do |config|
        config.cname  = "assethost.com"
        config.bucket = "bucketname"
        config.key_prefix = ""
        config.s3_config = "#{RAILS_ROOT}/config/s3.yml"
        config.enabled = true
        config.exclude_pattern = /stylesheets/
      end
    end
    
    should "extend rails_asset_id() w/ CDN" do
      assert_equal '8ed41cb87', rails_asset_id("/javascripts/application.js")
      assert_equal '',          rails_asset_id("/javascripts/does_not_exist.js")
      
      timestamp = File.mtime(ActionView::Helpers::AssetTagHelper::ASSETS_DIR+"/stylesheets/style.css").to_i.to_s
      assert_equal timestamp,   rails_asset_id("/stylesheets/style.css")
      assert_equal '',   rails_asset_id("/stylesheets/does_not_exist.css")
    end
    
    should "handle rewrite_asset_path() w/ CDN" do
      assert_equal '/8ed41cb87/javascripts/application.js', rewrite_asset_path("/javascripts/application.js")
      assert_equal '/javascripts/does_not_exist.js',        rewrite_asset_path("/javascripts/does_not_exist.js")

      asset_id = rails_asset_id('/stylesheets/style.css')
      assert_equal "/stylesheets/style.css?#{asset_id}",  rewrite_asset_path("/stylesheets/style.css")
      assert_equal "/stylesheets/style.css?#{asset_id}",  rewrite_asset_path("/stylesheets/style.css")
      assert_equal '/stylesheets/does_not_exist.css', rewrite_asset_path("/stylesheets/does_not_exist.css")
    end
  end
end
