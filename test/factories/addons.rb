# frozen_string_literal: true
# == Schema Information
#
# Table name: addons
#
#  id                           :integer          not null, primary key
#  name                         :string
#  repository_url               :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  latest_version               :string
#  description                  :string
#  license                      :string
#  npm_author_id                :integer
#  latest_version_date          :datetime
#  deprecated                   :boolean          default(FALSE)
#  note                         :text
#  official                     :boolean          default(FALSE)
#  cli_dependency               :boolean          default(FALSE)
#  hidden                       :boolean          default(FALSE)
#  github_user                  :string
#  github_repo                  :string
#  has_invalid_github_repo      :boolean          default(FALSE)
#  rendered_note                :text
#  last_month_downloads         :integer
#  is_top_downloaded            :boolean          default(FALSE)
#  is_top_starred               :boolean          default(FALSE)
#  score                        :decimal(5, 2)
#  published_date               :datetime
#  last_seen_in_npm             :datetime
#  is_wip                       :boolean          default(FALSE), not null
#  demo_url                     :string
#  ranking                      :integer
#  latest_addon_version_id      :integer
#  package_info_last_updated_at :datetime
#  repo_info_last_updated_at    :datetime
#  latest_review_id             :integer
#  override_repository_url      :string
#  extends_ember_cli            :boolean
#  extends_ember                :boolean
#  is_monorepo                  :boolean
#
# Indexes
#
#  index_addons_on_latest_addon_version_id  (latest_addon_version_id)
#  index_addons_on_latest_review_id         (latest_review_id)
#  index_addons_on_name                     (name) UNIQUE
#  index_addons_on_npm_author_id            (npm_author_id)
#
# Foreign Keys
#
#  fk_rails_...  (latest_addon_version_id => addon_versions.id)
#  fk_rails_...  (latest_review_id => reviews.id)
#

FactoryBot.define do
  factory :addon do
    name { SecureRandom.hex }
    deprecated false
    official false
    hidden false
    association :author, factory: :npm_author
  end

  trait :basic do
  end

  trait :offical do
    name { "official-#{SecureRandom.hex}" }
    official true
  end

  trait :deprecated do
    name { "deprecated-#{SecureRandom.hex}" }
    deprecated true
  end

  trait :hidden do
    name { "hidden-#{SecureRandom.hex}" }
    hidden true
  end
end
