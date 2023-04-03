# frozen_string_literal: true

require 'test_helper'

class AuditUpdaterTest < ActiveSupport::TestCase
  test '#update saves linter results' do
    addon = create(:addon, :with_reviewed_version)
    version = addon.latest_addon_version

    create_updater(addon).update(linter)

    result = LintResult.last

    assert_equal result.addon.id, addon.id
    assert_equal result.addon_version.id, version.id
    assert_equal result.sha, 'abcd3f'
    assert_equal result.results.length, lint_results.length
  end

  test '#update saves audits' do
    addon = create(:addon, :with_reviewed_version)
    version = addon.latest_addon_version

    rules = AuditUpdater::RULE_MAP.keys

    create_updater(addon).update(linter)

    audits = Audit.all

    assert_equal audits.length, rules.length, 'One audit for each rule'

    audits.each do |a|
      assert_equal a.addon_id, addon.id
      assert_equal a.addon_version_id, version.id
      assert_equal a.sha, 'abcd3f'
    end

    no_jquery = Audit.where(audit_type: 'no-jquery').first
    assert_equal false, no_jquery.value
    assert_equal 3, no_jquery.results.length

    no_jquery_integration = Audit.where(audit_type: 'no-jquery-integration').first
    assert_equal false, no_jquery_integration.value
    assert_equal 2, no_jquery_integration.results.length

    no_observers = Audit.where(audit_type: 'no-observers').first
    assert_equal true, no_observers.value
    assert_nil no_observers.results

    no_new_mixins = Audit.where(audit_type: 'no-new-mixins').first
    assert_equal true, no_new_mixins.value
    assert_nil no_new_mixins.results

    no_old_shims = Audit.where(audit_type: 'no-old-shims').first
    assert_equal true, no_old_shims.value
    assert_nil no_old_shims.results
  end

  test '#update reuses existing audit for same addon version and audit type' do
    addon = create(:addon, :with_reviewed_version)

    rules = AuditUpdater::RULE_MAP.keys

    create_updater(addon).update(linter)

    audits = Audit.all

    assert_equal audits.length, rules.length, 'One audit for each rule'

    no_jquery = Audit.where(audit_type: 'no-jquery').first
    assert_equal false, no_jquery.value
    assert_equal 3, no_jquery.results.length

    create_updater(addon).update(linter([]))

    audits.reload

    assert_equal audits.length, rules.length, 'One audit for each rule'
    no_jquery = Audit.where(audit_type: 'no-jquery').first
    assert_equal true, no_jquery.value
    assert_nil no_jquery.results
  end

  private

  def create_updater(addon)
    AuditUpdater.new(addon)
  end

  def linter(results = lint_results)
    OpenStruct.new(run: results, sha: 'abcd3f')
  end

  def lint_results
    LINT_RESULTS
  end

  LINT_RESULTS = [
    { filePath: 'addon/components/ember-scrollable.js',
      messages: [{
        'ruleId' => 'ember/no-jquery',
        'severity' => 2,
        'message' => 'Do not use jQuery',
        'line' => 147, 'column' => 5,
        'nodeType' => 'ThisExpression',
        'endLine' => 147, 'endColumn' => 9
      },
                 {
                   'ruleId' => 'ember-observer/no-jquery-integration',
                   'severity' => 2,
                   'message' => 'Do not use jQuery integration',
                   'line' => 147,
                   'column' => 5,
                   'nodeType' => 'ThisExpression',
                   'endLine' => 147,
                   'endColumn' => 9
                 }],
      errorCount: 2,
      warningCount: 0 },
    { filePath: 'addon/components/ember-scrollbar.js',
      messages: [
        {
          'ruleId' => 'ember/no-jquery',
          'severity' => 2,
          'message' => 'Do not use jQuery',
          'line' => 120,
          'column' => 22,
          'nodeType' => 'ThisExpression',
          'endLine' => 120,
          'endColumn' => 26
        },
        {
          'ruleId' => 'ember-observer/no-jquery-integration',
          'severity' => 2,
          'message' => 'Do not use jQuery integration',
          'line' => 120,
          'column' => 22,
          'nodeType' => 'ThisExpression',
          'endLine' => 120,
          'endColumn' => 26
        },
        {
          'ruleId' => 'ember/no-jquery',
          'severity' => 2,
          'message' => 'Do not use jQuery',
          'line' => 169,
          'column' => 12,
          'nodeType' => 'ThisExpression',
          'endLine' => 169,
          'endColumn' => 16
        }
      ],
      errorCount: 3,
      warningCount: 0 }
  ].freeze
end
