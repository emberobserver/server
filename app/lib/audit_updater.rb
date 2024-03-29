# frozen_string_literal: true

class AuditUpdater
  def initialize(addon)
    @addon = addon
  end

  def update(linter = create_linter)
    results = linter.run
    sha = linter.sha
    save_results(results, sha)
    save_audits(results, sha)
  end

  private

  attr_reader :addon

  def save_results(results, sha)
    lint_result = LintResult.find_or_create_by!(addon_id: addon.id, addon_version_id: addon.latest_addon_version.id)
    lint_result.update(results: results, sha: sha)
  end

  def save_audits(results, sha)
    by_rule = results_by_rule(results)
    RULE_MAP.each do |lint_rule, audit_type|
      audit = Audit.find_or_create_by!(addon_id: addon.id, addon_version_id: addon.latest_addon_version.id, audit_type: audit_type)
      if by_rule[lint_rule]
        audit.update(value: false, results: by_rule[lint_rule], audit_type: audit_type, sha: sha)
      else
        audit.update(value: true, results: nil, audit_type: audit_type, sha: sha)
      end
    end
  end

  def results_by_rule(results)
    messages = results.map { |o| o[:messages] }.flatten
    messages.group_by do |m|
      m['ruleId']
    end
  end

  def create_linter
    Linter.new(addon)
  end

  RULE_MAP = {
    'ember/no-jquery' => 'no-jquery',
    'ember/no-observers' => 'no-observers',
    'ember/no-new-mixins' => 'no-new-mixins',
    'ember/no-old-shims' => 'no-old-shims',
    'ember/no-classic-classes' => 'no-classic-classes',
    'ember/no-classic-components' => 'no-classic-components',
    'ember/no-computed-properties-in-native-classes' => 'no-computed-properties-in-native-classes',
    'ember/no-get' => 'no-get',
    'ember/no-get-with-default' => 'no-get-with-default',
    'ember-observer/no-ember-components' => 'no-ember-components',
    'ember-observer/no-glimmer-components' => 'no-glimmer-components',
    'ember-observer/no-jquery-integration' => 'no-jquery-integration',
    'ember-observer/no-tracked' => 'no-tracked'
  }.freeze
end
