# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_npm_keywords
#
#  addon_id       :integer
#  npm_keyword_id :integer
#
# Indexes
#
#  index_addon_npm_keywords_on_addon_id        (addon_id)
#  index_addon_npm_keywords_on_npm_keyword_id  (npm_keyword_id)
#

class AddonNpmKeyword < ApplicationRecord
  belongs_to :addon
  belongs_to :npm_keyword
end
