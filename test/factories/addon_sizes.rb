# == Schema Information
#
# Table name: addon_sizes
#
#  id               :integer          not null, primary key
#  addon_version_id :integer
#  app_js_size      :integer
#  app_css_size     :integer
#  vendor_js_size   :integer
#  vendor_css_size  :integer
#  other_js_size    :integer
#  other_css_size   :integer
#
# Indexes
#
#  index_addon_sizes_on_addon_version_id  (addon_version_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#


FactoryBot.define do
  factory :addon_size do

  end
end
