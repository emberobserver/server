# frozen_string_literal: true

class AddonDependencyDataBackfill
  UPDATE_SQL = 'update addon_version_dependencies set package_addon_id = ? where id = ?'
  DROP_INDEX_SQL = 'DROP INDEX index_addon_version_dependencies_on_package_addon_id'
  CREATE_INDEX_SQL = 'CREATE INDEX index_addon_version_dependencies_on_package_addon_id ON addon_version_dependencies(package_addon_id)'

  def self.run
    Rails.logger.info("Starting backfill at #{DateTime.now}")

    addons = Addon.pluck(:name, :id)
    addon_lookup = Hash[addons]

    latest_version_ids = Addon.where.not(latest_addon_version_id: nil).pluck(:latest_addon_version_id)
    dependencies = AddonVersionDependency.where('addon_version_id in (?)', latest_version_ids)

    Rails.logger.info("Updating #{dependencies.count} dependencies for the #{latest_version_ids.count} latest addon versions...")
    ActiveRecord::Base.connection.execute(DROP_INDEX_SQL)

    dependencies.in_batches.each_with_index do |dependencies, batch_index|
      puts "Processing batch ##{batch_index}"

      ActiveRecord::Base.transaction do
        dependencies.pluck(:id, :package).each do |dependency_tuple|
          package_addon_id = addon_lookup[dependency_tuple[1]]
          if package_addon_id
            sql = ActiveRecord::Base.send(:sanitize_sql_array, [UPDATE_SQL, package_addon_id, dependency_tuple[0]])
            ActiveRecord::Base.connection.execute(sql)
          end
          #dependency.update_columns(package_addon_id: addon_lookup[dependency.package]) if addon_lookup[dependency.package]
        end
      end
    end

    ActiveRecord::Base.connection.execute(CREATE_INDEX_SQL)
    Rails.logger.info("Done at #{DateTime.now}")
  end
end
