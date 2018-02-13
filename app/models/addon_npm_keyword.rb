# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_npm_keywords
#
#  addon_id       :integer
#  npm_keyword_id :integer
#

class AddonNpmKeyword < ApplicationRecord
  belongs_to :addon
  belongs_to :npm_keyword
end
