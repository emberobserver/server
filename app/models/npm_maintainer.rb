# frozen_string_literal: true

# == Schema Information
#
# Table name: npm_maintainers
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  gravatar   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NpmMaintainer < ApplicationRecord
  has_many :addon_maintainers
  has_many :addons, through: :addon_maintainers

  def visible_addons
    addons.where(hidden: false)
  end
end
