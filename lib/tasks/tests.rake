namespace :tests do
  task queue_canary_tests: :environment do
    Addon.ranked.each do |addon|
      PendingBuild.create!(
        addon_version: addon.newest_version,
        canary: true
      )
    end
  end
end
