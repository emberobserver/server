class PackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :npmjs_url, :repository_url
end
