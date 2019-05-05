# frozen_string_literal: true

require 'test_helper'

class AssetSizeParserTest < ActiveSupport::TestCase
  test 'returns hash of asset sizes' do
    parser = AssetSizeParser.new(asset_size_json)
    first_file = {
      'name' => 'dist/assets/my-app-7ed61c3f6c1b68080e1901c27e8c1fee.js',
      'size' => 5114,
      'gzipSize' => 1448
    }
    json = parser.asset_size_json

    assert json['files'].present?
    assert_equal json['files'][0], first_file
  end

  test 'ignores deprecation warnings' do
    parser = AssetSizeParser.new(asset_size_json_with_deprecations)
    first_file = {
      'name' => 'dist/assets/my-app-7ed61c3f6c1b68080e1901c27e8c1fee.js',
      'size' => 5114,
      'gzipSize' => 1448
    }
    json = parser.asset_size_json

    assert json['files'].present?
    assert_equal json['files'][0], first_file
  end

  test 'when given non-json' do
    parser = AssetSizeParser.new('something unexpected')
    assert_raises AssetSizeParser::ParseError do
      parser.asset_size_json
    end
  end

  def asset_size_json
    <<~JSON
      {"files":[{"name":"dist/assets/my-app-7ed61c3f6c1b68080e1901c27e8c1fee.js","size":5114,"gzipSize":1448},{"name":"dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css","size":0,"gzipSize":20},{"name":"dist/assets/vendor-2cd54805ca70d41c1e600e0e3b90631c.js","size":749443,"gzipSize":197335},{"name":"dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css","size":0,"gzipSize":20}]}
    JSON
  end

  def asset_size_json_with_deprecations
    <<~JSON
      DEPRECATION: ember-cli-babel 5.x has been deprecated. Please upgrade to at least ember-cli-babel 6.6. Version 5.2.8 located: my-app -> ember-cli-diff -> ember-cli-htmlbars-inline-precompile -> ember-cli-babel
      DEPRECATION: ember-cli-babel 5.x has been deprecated. Please upgrade to at least ember-cli-babel 6.6. Version 5.2.8 located: my-app -> ember-cli-diff -> ember-cli-babel
      {"files":[{"name":"dist/assets/my-app-7ed61c3f6c1b68080e1901c27e8c1fee.js","size":5114,"gzipSize":1448},{"name":"dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css","size":0,"gzipSize":20},{"name":"dist/assets/vendor-2cd54805ca70d41c1e600e0e3b90631c.js","size":749443,"gzipSize":197335},{"name":"dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css","size":0,"gzipSize":20}]}
    JSON
  end
end
