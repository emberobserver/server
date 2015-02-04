class PackageSerializer < ApplicationSerializer
  attributes :id, :name, :repository_url,
             :latest_version, :latest_version_date,
             :description
end
