# frozen_string_literal: true

# == Schema Information
#
# Table name: lint_results
#
#  id               :integer          not null, primary key
#  addon_id         :integer
#  addon_version_id :integer
#  results          :jsonb
#  sha              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_lint_results_on_addon_id          (addon_id)
#  index_lint_results_on_addon_version_id  (addon_version_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_id => addons.id)
#  fk_rails_...  (addon_version_id => addon_versions.id)
#

class LintResult < ApplicationRecord
  belongs_to :addon
  belongs_to :addon_version
end
