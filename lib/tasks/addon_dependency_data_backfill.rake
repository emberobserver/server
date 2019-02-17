# frozen_string_literal: true

namespace :data do
  task backfill_package_addon_ids: :environment do
    AddonDependencyDataBackfill.run
  end
end
