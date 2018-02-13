# frozen_string_literal: true

# == Schema Information
#
# Table name: addon_maintainers
#
#  addon_id          :integer
#  npm_maintainer_id :integer
#

class AddonMaintainer < ApplicationRecord
  belongs_to :addon
  belongs_to :npm_maintainer
end
