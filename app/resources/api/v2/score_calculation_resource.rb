# frozen_string_literal: true

class API::V2::ScoreCalculationResource < JSONAPI::Resource
  immutable
  attributes :info

  has_one :addon
  has_one :addon_verion

  filter :addon_id

  filter :latest, apply: ->(records, _value, _options) {
    records.order('created_at DESC').limit(1)
  }

  def info
    @model.info.deep_transform_keys { |key| key.camelize(:lower) }
  end
end
