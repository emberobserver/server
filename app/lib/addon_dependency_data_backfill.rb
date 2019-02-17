# frozen_string_literal: true

class AddonDependencyDataBackfill
  UPDATE_SQL = <<~SQL
    with latest_versions as (
      select addons.latest_addon_version_id
      from addons where latest_addon_version_id is not null
    )

    update addon_version_dependencies
    set package_addon_id = addons.id
    from
      addons
      where package = addons.name
      and addon_version_dependencies.addon_version_id in (select * from latest_versions);
  SQL

  def self.run
    Rails.logger.info("Starting backfill at #{DateTime.now}")
    ActiveRecord::Base.connection.execute(UPDATE_SQL)
    Rails.logger.info("Done at #{DateTime.now}")
  end
end
