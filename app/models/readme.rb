# frozen_string_literal: true
# == Schema Information
#
# Table name: readmes
#
#  id       :integer          not null, primary key
#  contents :text
#  addon_id :integer
#
# Indexes
#
#  index_readmes_on_addon_id  (addon_id)
#

class Readme < ApplicationRecord
  belongs_to :addon
end
