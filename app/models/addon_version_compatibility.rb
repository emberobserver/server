# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_version_compatibilities
#
#  id               :integer          not null, primary key
#  addon_version_id :integer
#  package          :string
#  version          :string
#
# Indexes
#
#  index_addon_version_compatibilities_on_addon_version_id  (addon_version_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_version_id => addon_versions.id)
#

class AddonVersionCompatibility < ApplicationRecord
  belongs_to :addon_version
end
