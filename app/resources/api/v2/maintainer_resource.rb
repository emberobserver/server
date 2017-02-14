class API::V2::MaintainerResource < JSONAPI::Resource
  immutable
  model_name 'NpmMaintainer'

  attributes :name, :gravatar
  has_many :addons

  filter :name

  def self.find(filters, options = {})
    no_filter = filters.keys == []
    raise Forbidden if no_filter
    super
  end
end
