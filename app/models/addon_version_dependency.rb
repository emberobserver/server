# frozen_string_literal: true
# == Schema Information
#
# Table name: addon_version_dependencies
#
#  id               :integer          not null, primary key
#  package          :string
#  version          :string
#  dependency_type  :string
#  addon_version_id :integer
#
# Indexes
#
#  index_addon_version_dependencies_on_addon_version_id  (addon_version_id)
#

class AddonVersionDependency < ApplicationRecord
  belongs_to :addon_version
end
