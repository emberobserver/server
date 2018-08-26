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
      { 'name' => 'dist/assets/my-app-4de90fc813bff2b33b61424f89ab694f.js', 'size' => 4356,'gzipSize' => 1315 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css','size' => 0,'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-a6d7c6355370786667cbe7d22c954542.js','size' => 752816,'gzipSize' => 192342 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css','size' => 0,'gzipSize' => 20 }
    ]}

    new_sizes = { 'files' => [
      { 'name' => 'dist/assets/my-app-3b7e1b1790a262fb98900004fe95f989.js','size' => 6316,'gzipSize' => 1446 },
      { 'name' => 'dist/assets/my-app-d41d8cd98f00b204e9800998ecf8427e.css','size' => 0,'gzipSize' => 20 },
      { 'name' => 'dist/assets/vendor-7b7fa6908e8cf411d0a74286b5911772.js','size' => 767098,'gzipSize' => 196131 },
      { 'name' => 'dist/assets/vendor-d41d8cd98f00b204e9800998ecf8427e.css','size' => 0,'gzipSize' => 20 }
    ]}

    diff = AddonSizeDiff.new(base_sizes, new_sizes)

    assert_equal 1960, diff.app_js
    assert_equal 0, diff.app_css
    assert_equal 14282, diff.vendor_js
    assert_equal 0, diff.vendor_css
  end
end
