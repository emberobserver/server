# frozen_string_literal: true
# == Schema Information
#
# Table name: category_addons
#
#  id          :integer          not null, primary key
#  category_id :integer
#  addon_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_category_addons_on_addon_id     (addon_id)
#  index_category_addons_on_category_id  (category_id)
#

class CategoryAddon < ApplicationRecord
  belongs_to :category
  belongs_to :addon
end
