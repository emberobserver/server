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

class BuildServerSerializer < ApplicationSerializer
  attributes :id, :name, :token, :created_at
end
