class NpmKeywordSerializer < ApplicationSerializer
  attributes :id, :keyword
  has_many :addons
end
