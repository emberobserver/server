# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_sizes
#
#  id              :integer          not null, primary key
#  addon_id        :integer
#  app_js_size     :integer
#  app_css_size    :integer
#  vendor_js_size  :integer
#  vendor_css_size :integer
#
# Indexes
#
#  index_addon_sizes_on_addon_id  (addon_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_id => addons.id)
#

require 'test_helper'

class AddonSizeDiffTest < ActiveSupport::TestCase
  test 'generates size diffs' do
    base_sizes = { 'files' => [
      { 'name' => 'dist/assets/my-app-4de90fc813bff2b33b61424f89ab694f.js', 'size' => 4356, 'gzipSize' => 1315 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-a6d7c6355370786667cbe7d22c954542.js', 'size' => 752816, 'gzipSize' => 192342 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 }
    ] }

    new_sizes = { 'files' => [
      { 'name' => 'dist/assets/my-app-3b7e1b1790a262fb98900004fe95f989.js', 'size' => 6316, 'gzipSize' => 1446 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-7b7fa6908e8cf411d0a74286b5911772.js', 'size' => 767098, 'gzipSize' => 196131 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 }
    ] }

    diff = AddonSizeDiff.new(base_sizes, new_sizes)

    assert_equal 1960, diff.app_js
    assert_equal 0, diff.app_css
    assert_equal 14282, diff.vendor_js
    assert_equal 0, diff.vendor_css
  end

  test 'diff includes other css' do
    base_sizes = { 'files' => [
      { 'name' => 'dist/assets/my-app-4de90fc813bff2b33b61424f89ab694f.js', 'size' => 4356, 'gzipSize' => 1315 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-a6d7c6355370786667cbe7d22c954542.js', 'size' => 752816, 'gzipSize' => 192342 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 }
    ] }

    new_sizes = { 'files' => [
      { 'name' => 'dist/assets/admin-67f49449dbf27f1d268ebba5cf966dd7.css', 'size' => 863, 'gzipSize' => 414 },
      { 'name' => 'dist/assets/bootstrap/bootstrap-5eee748576ad5c9ce0d2c08add439740.css', 'size' => 117029, 'gzipSize' => 19705 },
      { 'name' => 'dist/assets/bootstrap/bootstrap-colorpicker-cd6b85744f02785c6a559b0c112166c6.css', 'size' => 3823, 'gzipSize' => 999 },
      { 'name' => 'dist/assets/bootstrap/skin-blue-light.min-3fa36aadd4f915a4edf162dacf3c6305.css', 'size' => 3553, 'gzipSize' => 772 },
      { 'name' => 'dist/assets/bootstrap/daterangepicker/daterangepicker-bs3-978e4f9b1007d31362edaa4c596fc41c.css', 'size' => 5682, 'gzipSize' => 1427 },
      { 'name' => 'dist/assets/bootstrap/skin-blue-1f897de6e621f44b09600981216c40ab.css', 'size' => 2715, 'gzipSize' => 685 },
      { 'name' => 'dist/assets/bootstrap/skin-blue-light.min-3fa36aadd4f915a4edf162dacf3c6305.css', 'size' => 3553, 'gzipSize' => 772 },
      { 'name' => 'dist/assets/bootstrap/style-73750f83ab2817e0b3ff76e573d7af41.css', 'size' => 477, 'gzipSize' => 274 },
      { 'name' => 'dist/assets/icheck/blue-96b3defbb36697cb2afd6baf635c955e.css', 'size' => 1199, 'gzipSize' => 385 },
      { 'name' => 'dist/assets/my-app-0a81075305b66900cc65d35e3cec4703.js', 'size' => 4700, 'gzipSize' => 1394 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-533e4f6646796adaa38762a4ef87d5f8.js', 'size' => 948000, 'gzipSize' => 250228 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 }
    ] }

    diff = AddonSizeDiff.new(base_sizes, new_sizes)
    assert_equal 138894, diff.other_css
  end

  test 'diff includes other js' do
    base_sizes = { 'files' => [
      { 'name' => 'dist/assets/my-app-4de90fc813bff2b33b61424f89ab694f.js', 'size' => 4356, 'gzipSize' => 1315 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-a6d7c6355370786667cbe7d22c954542.js', 'size' => 752816, 'gzipSize' => 192342 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 }
    ] }

    new_sizes = { 'files' => [
      { 'name' => 'dist/assets/intl-4d7d43141e437dac353033ef26ee0bf4.js', 'size' => 40783, 'gzipSize' => 13637 },
      { 'name' => 'dist/assets/intl/intl.complete-f0ad87362f2317fce81ddadbcb15c7bc.js', 'size' => 934663, 'gzipSize' => 191766 },
      { 'name' => 'dist/assets/intl/intl.min-7e337c208265d304ec352cdf1c1be837.js', 'size' => 40900, 'gzipSize' => 13709 },
      { 'name' => 'dist/assets/intl/locales/af-269b8b0494042b1da5a5b5bd4297f046.js', 'size' => 26018, 'gzipSize' => 4020 },
      { 'name' => 'dist/assets/intl/locales/af-na-801e125e79620f4fffc3550223c135b3.js', 'size' => 26029, 'gzipSize' => 4027 },
      { 'name' => 'dist/assets/intl/locales/af-za-83ffb2682c8cb29558b492a359a6892d.js', 'size' => 26021, 'gzipSize' => 4024 },
      { 'name' => 'dist/assets/intl/locales/en-je-8270c6f5f23ea534a6dcd25e10d22660.js', 'size' => 25960, 'gzipSize' => 4064 },
      { 'name' => 'dist/assets/intl/locales/zu-za-b3de8f5eba8df468738b5f8e9d2742fd.js', 'size' => 26103, 'gzipSize' => 4005 },
      { 'name' => 'dist/assets/my-app-351bee7e5f7c996b22d7895f64af2ab7.js', 'size' => 8510, 'gzipSize' => 1705 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-6be7c2dea833256277e60881bd358528.js', 'size' => 798617, 'gzipSize' => 206910 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 }
    ] }

    diff = AddonSizeDiff.new(base_sizes, new_sizes)
    assert_equal 1146477, diff.other_js
  end

  test 'diffs can be converted to json' do
    base_sizes = { 'files' => [
      { 'name' => 'dist/assets/my-app-4de90fc813bff2b33b61424f89ab694f.js', 'size' => 4356, 'gzipSize' => 1315 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-a6d7c6355370786667cbe7d22c954542.js', 'size' => 752816, 'gzipSize' => 192342 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 }
    ] }

    new_sizes = { 'files' => [
      { 'name' => 'dist/assets/my-app-3b7e1b1790a262fb98900004fe95f989.js', 'size' => 6316, 'gzipSize' => 1446 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-7b7fa6908e8cf411d0a74286b5911772.js', 'size' => 767098, 'gzipSize' => 196131 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css', 'size' => 0, 'gzipSize' => 20 },
      { 'name' => 'dist/assets/intl-4d7d43141e437dac353033ef26ee0bf4.js', 'size' => 40783, 'gzipSize' => 13637 },
      { 'name' => 'dist/assets/intl/intl.complete-f0ad87362f2317fce81ddadbcb15c7bc.js', 'size' => 934663, 'gzipSize' => 191766 }
    ] }

    diff = AddonSizeDiff.new(base_sizes, new_sizes)
    json = diff.to_json

    assert_equal json['appJsSize'], diff.app_js
    assert_equal json['appCssSize'], diff.app_css
    assert_equal json['vendorJsSize'], diff.vendor_js
    assert_equal json['vendorCssSize'], diff.vendor_css
    assert_equal json['otherJsSize'], diff.other_js
    assert_equal json['otherCssSize'], diff.other_css
  end
end
