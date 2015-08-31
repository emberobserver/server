class NpmMaintainerSerializer < ApplicationSerializer
  attributes :id, :name, :gravatar
  has_many :addons, include: false

  def addons
    object.visible_addons
  end
end
