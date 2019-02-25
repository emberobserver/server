# == Schema Information
#
# Table name: ember_versions
#
#  id         :integer          not null, primary key
#  version    :string           not null
#  released   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmberVersion < ApplicationRecord
  def self.releases
    where("version NOT LIKE '%beta%'")
  end

  def self.major_and_minor
    where("version LIKE '%.0'")
  end
end
