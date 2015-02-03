class PackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :repository_url, :latest_version, :latest_version_date, :description
end
