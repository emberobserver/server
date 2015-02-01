class API::ReviewSerializer < ActiveModel::Serializer
  attributes :id, :version, :body
  has_one :package
end
