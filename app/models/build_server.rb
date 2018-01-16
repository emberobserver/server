# == Schema Information
#
# Table name: build_servers
#
#  id         :integer          not null, primary key
#  name       :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BuildServer < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  validates :token, uniqueness: true

  has_secure_token
end
