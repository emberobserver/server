require 'test_helper'

class CodeSearchTest < ActiveSupport::TestCase

  test 'can search for files containing source code within an addon' do
    code_search = CodeSearch.new(SearchEngineStub.new, SedStub.new)
    results = code_search.retrieve_source('Ember.computed', 'ember-foo')

    assert_equal(1, results.length)

    result = results[0]
    assert_equal('app/routes/search.js', result[:filename])
    assert_equal(8, result[:line_number])

    lines = result[:lines]

    first_line = lines.first
    assert_equal("if (user) {", first_line[:text])
    assert_equal(4, first_line[:number])

    last_line = lines.last
    assert_equal("});", last_line[:text])
    assert_equal(9, last_line[:number])
  end

  test 'can search for all addons containing code' do
    code_search = CodeSearch.new(SearchEngineStub.new, SedStub.new)
    results = code_search.retrieve_addons('Ember.computed')

    assert_equal(2, results.length)
    foo_addon_result = results.find { |result| result[:addon] == 'ember-foo' }
    bar_addon_result = results.find { |result| result[:addon] == 'ember-bar' }

    assert_equal(1, foo_addon_result[:count])
    assert_equal(2, bar_addon_result[:count])
  end

  class SearchEngineStub
    def query(term, addon_dir = nil)
      if addon_dir
        ["#{Rails.root}/source/ember-foo/app/routes/search.js:8:  headers: Ember.computed(function() {"]
      else
        [
          "#{Rails.root}/source/ember-foo/app/routes/search.js:8:  headers: Ember.computed(function() {",
          "#{Rails.root}/source/ember-bar/app/routes/index.js:8:  headers: Ember.computed(function() {",
          "#{Rails.root}/source/ember-bar/app/components/contact-form.js:8:  headers: Ember.computed(function() {"
        ]
      end
    end
  end

  class SedStub
    def retrieve_match(filename, matched_line_number)
      [
        ["if (user) {", 4],
        ["  return { userId: user.id, token: user.token };", 5],
        ["} else {", 6],
        ["<b>      return new Mirage.Response(401);</b>", 7],
        ["}", 8],
        ["});", 9]
      ]
    end
  end
end
