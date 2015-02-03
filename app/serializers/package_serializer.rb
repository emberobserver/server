class PackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :npmjs_url, :repository_url, :latest_version, :latest_version_date, :description
end
