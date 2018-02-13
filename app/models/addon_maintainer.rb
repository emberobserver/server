# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_maintainers
#
#  addon_id          :integer
#  npm_maintainer_id :integer
#
# Indexes
#
#  index_addon_maintainers_on_addon_id                        (addon_id)
#  index_addon_maintainers_on_addon_id_and_npm_maintainer_id  (addon_id,npm_maintainer_id)
#  index_addon_maintainers_on_npm_maintainer_id               (npm_maintainer_id)
#

class AddonMaintainer < ApplicationRecord
  belongs_to :addon
  belongs_to :npm_maintainer
end
