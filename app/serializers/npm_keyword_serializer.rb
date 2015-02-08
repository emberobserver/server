class NpmKeywordSerializer < ApplicationSerializer
  attributes :id, :keyword
  has_many :addons, embed_in_root: false
end
