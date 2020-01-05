# frozen_string_literal: true

class API::V2::AuditResource < JSONAPI::Resource
  attributes :created_at, :sha, :value, :results, :override_value, :override_timestamp,
    :audit_type, :user_id

  has_one :version, class_name: 'Version', relation_name: 'addon_version', foreign_key: 'addon_version_id'
  has_one :addon

  filter :addon_version_id

  def self.find(filters, options = {})
    has_specified_filter = filters.keys == [:addon_version_id]
    raise Forbidden unless has_specified_filter
    super
  end

  def self.updatable_fields(context)
    return [] unless context[:current_user]
    %i[
      override_value
      override_timestamp
      user_id
    ]
  end

  def self.creatable_fields(context)
    return [] unless context[:current_user]
    %i[
      override_value
      override_timestamp
      audit_type
      version
      addon
      user_id
    ]
  end
end
