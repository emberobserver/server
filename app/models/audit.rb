# frozen_string_literal: true

# == Schema Information
#
# Table name: audits
#
#  id                 :integer          not null, primary key
#  addon_id           :integer
#  addon_version_id   :integer
#  value              :boolean
#  override_value     :boolean
#  user_id            :integer
#  override_timestamp :datetime
#  results            :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  sha                :string
#  audit_type         :string
#
# Indexes
#
#  index_audits_on_addon_id          (addon_id)
#  index_audits_on_addon_version_id  (addon_version_id)
#  index_audits_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_id => addons.id)
#  fk_rails_...  (addon_version_id => addon_versions.id)
#  fk_rails_...  (user_id => users.id)
#

class Audit < ApplicationRecord
  belongs_to :addon
  belongs_to :addon_version
end
