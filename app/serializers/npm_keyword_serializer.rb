class NpmKeywordSerializer < ApplicationSerializer
  attributes :id, :keyword
  has_many :packages
end
