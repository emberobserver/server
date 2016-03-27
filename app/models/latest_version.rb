# == Schema Information
#
# Table name: latest_versions
#
#  id         :integer          not null, primary key
#  package    :string
#  version    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LatestVersion < ActiveRecord::Base
  validates :package, uniqueness: true
end
