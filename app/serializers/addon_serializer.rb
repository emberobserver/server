class AddonSerializer < ApplicationSerializer
  attributes :id, :name, :repository_url,
             :latest_version, :latest_version_date,
             :description, :license
  has_many :addon_versions, embed_in_root: false
end
