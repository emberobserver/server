# frozen_string_literal: true
# == Schema Information
#
# Table name: addon_downloads
#
#  id        :integer          not null, primary key
#  addon_id  :integer
#  date      :date
#  downloads :integer
#
# Indexes
#
#  index_addon_downloads_on_addon_id  (addon_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_id => addons.id)
#

class AddonDownload < ApplicationRecord
  belongs_to :addon
end
