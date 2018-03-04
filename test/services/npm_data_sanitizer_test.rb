# frozen_string_literal: true

require 'test_helper'

class NpmDataSanitizerTest < ActiveSupport::TestCase
  test 'when url is nil' do
    assert_nil parsed_url(nil)
  end

  test 'removes extra slash after http' do
    assert_equal 'http://github.com/foo/bar', parsed_url('http:///github.com/foo/bar')
  end

  test 'removes git username' do
    assert_equal 'http://github.com/foo/bar', parsed_url('http://git@github.com/foo/bar')
  end

  test 'removes git+ from before https' do
    assert_equal 'https://github.com/foo/bar', parsed_url('git+https://github.com/foo/bar')
  end

  test 'replaces git+ssh with https' do
    assert_equal 'https://github.com/foo/bar', parsed_url('git+ssh://github.com/foo/bar')
  end

  test 'removes closing tick' do
    assert_equal 'http://github.com/foo/bar', parsed_url('http://github.com/foo/bar`')
  end

  test 'fixes multiple issues' do
    assert_equal 'http://github.com/foo/bar', parsed_url('http://git@github.com/foo/bar`')
    assert_equal 'https://github.com/foo/bar', parsed_url('git+https://git@github.com/foo/bar')
    assert_equal 'https://github.com/foo/bar', parsed_url('git+ssh://github.com/foo/bar`')
  end

  def parsed_url(raw_url)
    NpmDataSanitizer.repository_url(raw_url)
  end
end
