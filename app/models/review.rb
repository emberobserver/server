# == Schema Information
#
# Table name: reviews
#
#  id         :integer          not null, primary key
#  package_id :integer
#  version    :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Review < ActiveRecord::Base
  belongs_to :package
  has_many :evaluations
end
