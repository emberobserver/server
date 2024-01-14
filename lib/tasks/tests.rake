# frozen_string_literal: true

# Run builds of these types when we are enqueuing tests.
BUILD_TYPES = [:ember_version_compatibility, :embroider]

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
    Addon.top_n(200).with_valid_repo.map(&:latest_addon_version).each do |version|
      BUILD_TYPES.each do |build_type|
        if version.test_results.where(build_type: build_type).count == 0
          PendingBuild.create!(addon_version: version, build_type: build_type)
        end
      end
    end
  end

  task verify_queue: :environment do
    if PendingBuild.count > 0
      BuildQueueMailer.queue_not_empty.deliver_now
    end
  end
end
