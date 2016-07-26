# == Schema Information
#
# Table name: readmes
#
#  id       :integer          not null, primary key
#  contents :text
#  addon_id :integer
#

class ReadmeSerializer < ApplicationSerializer
  attributes :id, :contents
end
