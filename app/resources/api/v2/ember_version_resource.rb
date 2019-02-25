# frozen_string_literal: true

class API::V2::EmberVersionResource < JSONAPI::Resource
  immutable

  attributes :version, :released

  filter :release,
    verify: ->(values, context) {
      values.map { |v| v.to_s == 'true' }
    },
    apply: ->(records, value, _options) {
      value[0] ? records.releases : records
    }

  filter :major_and_minor,
    verify: ->(values, context) {
      values.map { |v| v.to_s == 'true' }
    },
    apply: ->(records, value, _options) {
      value[0] ? records.major_and_minor : records
    }
end
