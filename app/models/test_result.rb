# frozen_string_literal: true
# == Schema Information
#
# Table name: test_results
#
#  id                :integer          not null, primary key
#  addon_version_id  :integer
#  succeeded         :boolean
#  status_message    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  build_server_id   :integer
#  semver_string     :string
#  output            :text
#  output_format     :string           default("text"), not null
#  ember_try_results :jsonb
#  build_type        :string
#
# Indexes
#
#  index_test_results_on_addon_version_id  (addon_version_id)
#  index_test_results_on_build_server_id   (build_server_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#  fk_rails_...  (build_server_id => build_servers.id)
#

class TestResult < ApplicationRecord
  VALID_OUTPUT_FORMATS = %w[json text].freeze

  belongs_to :addon_version
  belongs_to :build_server
  has_many :ember_version_compatibilities

  validates :output_format, inclusion: { in: VALID_OUTPUT_FORMATS }
  validate :valid_output?

  private

  def valid_output?
    return unless output_format == 'json'

    begin
      JSON.parse(output)
    rescue JSON::ParserError
      errors.add(:output, 'must be valid JSON')
    end
  end
end
