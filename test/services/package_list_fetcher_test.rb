# frozen_string_literal: true

require 'test_helper'

class PackageListFetcherTest < ActiveSupport::TestCase

  test 'Simple request smaller than page size' do
    data = {
      objects: [
        { package: { name: "ember-try" } },
        { package: { name: "@ember/test-helpers" } },
        { package: { name: "ember-cli-mirage" } },
        { package: { name: "ember-feature-flags" } },
      ],
      total: 4
    }

    stub_page(response_from(data), { size: 250, from: 0 })
    results = PackageListFetcher.run

    assert_equal(4, results.length)
    assert_equal(%w(ember-try @ember/test-helpers ember-cli-mirage ember-feature-flags), results.map {|r| r["package"]["name"]})
  end

  test 'Multiple pages returns all matching packages' do
    page_1_data = {
      objects: [
        { package: { name: "ember-try" } },
        { package: { name: "@ember/test-helpers" } }
      ],
      total: 7
    }
    page_2_data = {
      objects: [
        { package: { name: "ember-cli-mirage" } },
        { package: { name: "ember-feature-flags" } }
      ],
      total: 7
    }

    page_3_data = {
      objects: [
        { package: { name: "ember-power-select" } },
        { package: { name: "ember-power-calendar" } }
      ],
      total: 7
    }

    page_4_data = {
      objects: [
        { package: { name: "ember-animation" } }
      ],
      total: 7
    }

    stub_page(response_from(page_1_data), { size: 2, from: 0 })
    stub_page(response_from(page_2_data), { size: 2, from: 2 })
    stub_page(response_from(page_3_data), { size: 2, from: 4 })
    stub_page(response_from(page_4_data), { size: 2, from: 6 })

    results = PackageListFetcher.run({ page_size: 2 })

    assert_equal(results.length, 7)
    assert_equal(%w(
      ember-try
      @ember/test-helpers
      ember-cli-mirage
      ember-feature-flags
      ember-power-select
      ember-power-calendar
      ember-animation
    ), results.map {|r| r["package"]["name"]})
  end

  test 'First page request times out' do
    stub_page(timed_out_response, { size: 250, from: 0 })
    results = PackageListFetcher.run

    assert_equal(results.length, 0)
  end

  test 'Multiple pages with some timing out returns everything fetched before the timeout' do
    page_1_data = {
      objects: [
        { package: { name: "ember-try" } },
        { package: { name: "@ember/test-helpers" } }
      ],
      total: 7
    }

    stub_page(response_from(page_1_data), { size: 2, from: 0 })
    stub_page(timed_out_response, { size: 2, from: 2 })

    results = PackageListFetcher.run({ page_size: 2 })

    assert_equal(2, results.length)
    assert_equal(%w(
      ember-try
      @ember/test-helpers
    ), results.map {|r| r["package"]["name"]})
  end

  test 'First page request fails' do
    stub_page(failed_response, { size: 250, from: 0 })
    results = PackageListFetcher.run

    assert_equal(results.length, 0)
  end

  test 'Multiple pages with some failing returns everything fetched before the failure' do
    page_1_data = {
      objects: [
        { package: { name: "ember-try" } },
        { package: { name: "@ember/test-helpers" } }
      ],
      total: 7
    }

    stub_page(response_from(page_1_data), { size: 2, from: 0 })
    stub_page(failed_response, { size: 2, from: 2 })

    results = PackageListFetcher.run({ page_size: 2 })

    assert_equal(2, results.length)
    assert_equal(%w(
      ember-try
      @ember/test-helpers
    ), results.map {|r| r["package"]["name"]})
  end

  test 'Empty response causes it to stop fetching' do
    empty_objects_data = {
      objects: [],
      total: 4
    }

    stub_page(response_from(empty_objects_data), { size: 250, from: 0 })
    results = PackageListFetcher.run

    assert_equal(0, results.length)
  end

  test 'Multiple pages of data with one empty response returns those fetched so far' do
    page_1_data = {
      objects: [
        { package: { name: "ember-try" } },
        { package: { name: "@ember/test-helpers" } }
      ],
      total: 7
    }

    empty_objects_data = {
      objects: [],
      total: 7
    }

    stub_page(response_from(page_1_data), { size: 2, from: 0 })
    stub_page(response_from(empty_objects_data), { size: 2, from: 2 })

    results = PackageListFetcher.run({ page_size: 2 })

    assert_equal(2, results.length)
    assert_equal(%w(
      ember-try
      @ember/test-helpers
    ), results.map {|r| r["package"]["name"]})
  end

  test 'Malformed response raises' do
    response = MockResponse.new({ body: '{ foo: {}' })
    stub_page(response, { size: 250, from: 0 })
    assert_raises JSON::ParserError do
      PackageListFetcher.run
    end
  end

  def stub_page(response, options)
    PackageListFetcher::Request.expects(:get).with(PackageListFetcher::FETCH_URL, { params: { size: options[:size], from: options[:from] } }).returns(response)
  end

  def response_from(data, options = { code: 200 })
    MockResponse.new({ body: data.to_json }.merge(options))
  end

  def timed_out_response
    MockResponse.new({ timed_out: true, success: false })
  end

  def failed_response
    MockResponse.new({ code: 500, success: false })
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

    def code
      @code
    end

    def body
      @body
    end
  end
end
