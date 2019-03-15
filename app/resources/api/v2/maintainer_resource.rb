# frozen_string_literal: true

class API::V2::MaintainerResource < JSONAPI::Resource
  immutable
  model_name 'NpmMaintainer'

  attributes :name, :gravatar
  has_many :addons

  filter :name, apply: ->(records, values, _options) {
    matching_records = records.where(name: values)
    unless matching_records.count == values.length
      missing_names = values - matching_records.map(&:name)
      raise JSONAPI::Exceptions::RecordNotFound, missing_names.first
    end
    matching_records
  }

  def self.find(filters, options = {})
    no_filter = filters.keys == []
    raise Forbidden if no_filter
    super
  end
end
