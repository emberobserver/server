# == Schema Information
#
# Table name: pending_builds
#
#  id                :integer          not null, primary key
#  addon_version_id  :integer
#  build_assigned_at :datetime
#  build_server_id   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  canary            :boolean          default(FALSE), not null
#

FactoryGirl.define do
  factory :pending_build do
    association :addon_version, :factory => [:addon_version, :basic]
  end
end
