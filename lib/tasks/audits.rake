# frozen_string_literal: true

namespace :audits do
  task enqueue: :environment do
    Addon.with_valid_repo.find_each do |addon|
      AuditWorker.perform_async(addon.id)
    end
  end
end
