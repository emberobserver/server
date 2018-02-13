# frozen_string_literal: true

# == Schema Information
#
# Table name: npm_keywords
#
#  id         :integer          not null, primary key
#  keyword    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NpmKeyword < ApplicationRecord
  has_many :addon_npm_keywords
  has_many :addons, through: :addon_npm_keywords
end
