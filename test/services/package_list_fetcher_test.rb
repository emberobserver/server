# frozen_string_literal: true

require 'test_helper'

class PackageListFetcherTest < ActiveSupport::TestCase
  setup do
    @couchdb_user = ENV['COUCHDB_USERNAME']
    @couchdb_pass = ENV['COUCHDB_PASSWORD']

    ENV['COUCHDB_USERNAME'] = 'test-user'
    ENV['COUCHDB_PASSWORD'] = 'test-password'
  end

  teardown do
    ENV['COUCHDB_USERNAME'] = @couchdb_user
    ENV['COUCHDB_PASSWORD'] = @couchdb_pass
  end

  test 'maps returned key/value to name/date' do
    data = {
      rows: [
        {
          key: 'ember-try',
          value: '2019-12-11T21:52:02.157Z'
        },
        {
          key: '@ember/test-helpers',
          value: '2019-10-25T20:19:45.594Z'
        },
        {
          key: 'ember-cli-mirage',
          value: '2019-12-16T18:37:31.102Z'
        },
        {
          key: 'ember-feature-flags',
          value: '2019-10-24T02:20:36.452Z'
        }
      ]
    }
    stub_page response_from(data)

    results = PackageListFetcher.run

    assert_equal 4, results.length
    assert_equal %w[ember-try @ember/test-helpers ember-cli-mirage ember-feature-flags], results.map { |r| r[:name] }
    assert_equal ['2019-12-11T21:52:02.157Z', '2019-10-25T20:19:45.594Z', '2019-12-16T18:37:31.102Z', '2019-10-24T02:20:36.452Z'], results.map { |r| r[:date] }
  end

  test 'returns an empty array if request times out' do
    stub_page timed_out_response

    results = PackageListFetcher.run

    assert_equal 0, results.length
  end

  test 'returns an empty array if request fails' do
    stub_page failed_response

    results = PackageListFetcher.run

    assert_equal 0, results.length
  end

  test 'malformed response raises' do
    response = MockResponse.new(body: '{ foo: {}')
    stub_page response
    assert_raises JSON::ParserError do
      PackageListFetcher.run
    end
  end

  def stub_page(response)
    PackageListFetcher::Request.expects(:get).with(PackageListFetcher::FETCH_URL, userpwd: 'test-user:test-password').returns(response)
  end

  def response_from(data, options = { code: 200 })
    MockResponse.new({ body: data.to_json }.merge(options))
  end

  def timed_out_response
    MockResponse.new(timed_out: true, success: false)
  end

  def failed_response
    MockResponse.new(code: 500, success: false)
  end

  class MockResponse
    def initialize(opts)
      options = { code: 200, success: true }.merge(opts)
      @body = options[:body]
      @code = options[:code]
      @timed_out = options[:timed_out]
      @success = options[:success]
    end

    def success?
      @success
    end

    def timed_out?
      @timed_out
    end

    attr_reader :code

    attr_reader :body
  end
end
