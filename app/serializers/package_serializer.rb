class PackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :npmjs_url, :github_url
end
