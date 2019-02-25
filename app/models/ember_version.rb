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
  def beta?
    /beta/ === version
  end

  def major_or_minor?
    /\.0$/ === version
  end
end
