class NpmMaintainerSerializer < ApplicationSerializer
  attributes :id, :name, :gravatar
  has_many :addons, include: false
end
