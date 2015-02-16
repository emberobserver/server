class NpmKeywordSerializer < ApplicationSerializer
  attributes :id, :keyword
  has_many :addons, include: false
end
