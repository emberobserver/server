# == Schema Information
#
# Table name: addon_downloads
#
#  id        :integer          not null, primary key
#  addon_id  :integer
#  date      :date
#  downloads :integer
#

class AddonDownload < ApplicationRecord
  belongs_to :addon
end
