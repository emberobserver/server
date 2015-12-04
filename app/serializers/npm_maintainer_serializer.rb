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

class NpmMaintainerSerializer < ApplicationSerializer
  attributes :id, :name, :gravatar
  has_many :addons, include: false

  def addons
    object.visible_addons
  end
end
