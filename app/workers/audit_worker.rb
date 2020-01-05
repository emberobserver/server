# frozen_string_literal: true

class AuditWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1

  def perform(addon_id)
    addon = Addon.find(addon_id)
    audit(addon)
  end

  private

  def audit(addon)
    AuditUpdater.new(addon).update
  end
end
