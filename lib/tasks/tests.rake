# frozen_string_literal: true

namespace :tests do
  task queue_canary_tests: :environment do
    Addon.ranked.each do |addon|
      PendingBuild.create!(
        addon_version: addon.newest_version,
        canary: true
      )
    end
  end

  task queue_tests: :environment do
    Addon.ranked
         .map(&:newest_version)
         .select { |version| version.test_results.where(canary: false).count == 0 }
         .each { |version| PendingBuild.create!(addon_version: version) }
  end
end
