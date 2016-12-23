class API::V2::ReviewResource < JSONAPI::Resource
  attributes :created_at, :has_tests, :has_readme,
             :is_more_than_empty_addon, :review, :is_open_source,
             :has_build#, :version_id, :addon_id

  has_one :version, class_name: 'Version', relation_name: 'addon_version'
end
