# == Schema Information
#
# Table name: metrics
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  details     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Metric < ActiveRecord::Base
  has_many :evaluations
end
