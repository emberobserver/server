class NpmUserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :gravatar

  has_many :addons, embed_in_root: false
end
