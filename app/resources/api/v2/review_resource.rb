# frozen_string_literal: true

class API::V2::ReviewResource < JSONAPI::Resource
  attributes :created_at, :has_tests, :has_readme,
    :review,
    :has_build

  has_one :version, class_name: 'Version', relation_name: 'addon_version', foreign_key: 'addon_version_id'

  def self.updatable_fields(_context)
    []
  end

  def self.creatable_fields(context)
    return [] unless context[:current_user]
    %i[
      has_tests has_readme
      review has_build version
    ]
  end
end
