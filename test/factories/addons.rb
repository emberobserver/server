# frozen_string_literal: true

# == Schema Information
#
# Table name: addons
#
#  id                      :integer          not null, primary key
#  name                    :string
#  repository_url          :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  latest_version          :string
#  description             :string
#  license                 :string
#  npm_author_id           :integer
#  latest_version_date     :datetime
#  deprecated              :boolean          default(FALSE)
#  note                    :text
#  official                :boolean          default(FALSE)
#  cli_dependency          :boolean          default(FALSE)
#  hidden                  :boolean          default(FALSE)
#  github_user             :string
#  github_repo             :string
#  has_invalid_github_repo :boolean          default(FALSE)
#  rendered_note           :text
#  last_month_downloads    :integer
#  is_top_downloaded       :boolean          default(FALSE)
#  is_top_starred          :boolean          default(FALSE)
#  score                   :integer
#  published_date          :datetime
#  last_seen_in_npm        :datetime
#  is_wip                  :boolean          default(FALSE), not null
#  demo_url                :string
#  ranking                 :integer
#  latest_addon_version_id :integer
#

FactoryGirl.define do
  factory :addon do
    name { SecureRandom.hex }
    deprecated false
    official false
    hidden false
    association :author, factory: :npm_author
  end

  trait :basic do
    name 'basic-addon'
  end

  trait :offical do
    name 'official-addon'
    official true
  end

  trait :deprecated do
    name 'deprecated-addon'
    deprecated true
  end

  trait :hidden do
    name 'hidden-addon'
    hidden true
  end
end
