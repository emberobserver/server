# == Schema Information
#
# Table name: readmes
#
#  id       :integer          not null, primary key
#  contents :text
#  addon_id :integer
#

class Readme < ActiveRecord::Base
  belongs_to :addon
end
