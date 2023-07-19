# frozen_string_literal: true

namespace :tests do
  task queue_canary_tests: :environment do
    Addon.top_n(200).with_valid_repo.each do |addon|
      PendingBuild.create!(
        addon_version: addon.latest_addon_version,
        build_type: :canary
      )
    end
  end

  task queue_tests: :environment do
    Addon.top_n(200).with_valid_repo
         .map(&:latest_addon_version)
         .select { |version| version.test_results.where(build_type: :ember_version_compatibility).count == 0 }
         .each { |version| PendingBuild.create!(addon_version: version, build_type: :ember_version_compatibility) }
  end

  task verify_queue: :environment do
    if PendingBuild.count > 0
      BuildQueueMailer.queue_not_empty.deliver_now
    end
  end
end
