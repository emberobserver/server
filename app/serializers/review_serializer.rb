class ReviewSerializer < ApplicationSerializer
  attributes :id, :version, :body
  has_one :package
end
