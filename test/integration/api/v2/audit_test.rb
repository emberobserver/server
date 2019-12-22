# frozen_string_literal: true

require 'test_helper'

class API::V2::AuditTest < IntegrationTest
  AUDIT_ATTRIBUTES = %w[
    created-at
    sha
    value
    results
    override-value
    override-timestamp
    audit-type
    user-id
  ].freeze

  AUDIT_RELATIONSHIPS = %w[
    version
    addon
  ].freeze

  test 'end user cannot fetch audits without a filter' do
    get '/api/v2/audits'
    assert_response 403
  end

  test 'end user cannot fetch individual audit' do
    audit = create :audit, :existing
    assert_raises ActionController::RoutingError do
      get "/api/v2/audits/#{audit.id}"
    end
  end

  test 'end user cannot update individual audit' do
    audit = create :audit, :existing
    assert_raises ActionController::RoutingError do
      patch "/api/v2/reviews/#{audit.id}"
    end
  end

  test 'end user cannot create audit' do
    create_audit({})

    assert_response 403
  end

  test 'admin user can create audit' do
    version = create :addon_version
    user = create(:user)
    auth_headers = authentication_headers_for(user)

    create_audit(
      attrs: {
        "override-value": 'true',
        "override-timestamp": Time.now.utc.iso8601,
        "audit-type": 'no-observers',
        "user-id": user.id
      },
      relationships: {
        addon: { data: { type: 'addons', id: version.addon.id } },
        version: { data: { type: 'versions', id: version.id } }
      },
      headers: auth_headers
    )

    assert_response 201
  end

  test 'end user can fetch an addons audits' do
    audit = create :audit, :existing
    version = create :addon_version, addon: audit.addon
    other_audit = create :audit, addon_version: version, addon: audit.addon,
                                 value: false, audit_type: 'no-jquery', results: [{ line: 38 }]
    another_audit = create :audit, addon_version: version, addon: audit.addon, value: false,
                                   audit_type: 'no-jquery'

    get '/api/v2/audits', params: { filter: { addon_version_id: version.id } }

    audit_response = json_response['data']
    assert_equal 2, audit_response.length, 'both audits for latest version returned'
    assert_equal other_audit.id.to_s, audit_response[0]['id'], 'Correct audits are in results'
    assert_equal another_audit.id.to_s, audit_response[1]['id'], 'Correct audits are in results'
    assert_equal 38, audit_response[0]['attributes']['results'][0]['line']
    assert_equal audit_response[0]['attributes'].keys, AUDIT_ATTRIBUTES, 'Audit response includes expected fields'
    assert_equal audit_response[0]['relationships'].keys, AUDIT_RELATIONSHIPS, 'Audit response includes expected relationships'
  end

  test 'end user cannot delete audit' do
    audit = create :audit, :existing

    assert_raises ActionController::RoutingError, 'Audits only have create, update, index routes' do
      delete "/api/v2/audits/#{audit.id}", headers: { CONTENT_TYPE: JSONAPI_TYPE }
    end
  end

  private

  def create_audit(options)
    post '/api/v2/audits',
      params: {
        data: {
          type: 'audits',
          attributes: options[:attrs] || {},
          relationships: options[:relationships] || {}
        }
      }.to_json,
      headers: { CONTENT_TYPE: JSONAPI_TYPE }.merge(options[:headers] || {})
  end
end
