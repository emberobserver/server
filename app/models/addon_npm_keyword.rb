# == Schema Information
#
# Table name: addon_npm_keywords
#
#  addon_id       :integer
#  npm_keyword_id :integer
#

class AddonNpmKeyword < ActiveRecord::Base
  belongs_to :addon
  belongs_to :npm_keyword
end
