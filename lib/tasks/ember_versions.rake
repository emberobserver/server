# frozen_string_literal: true

namespace :ember_versions do
  task update: :environment do
    ember_versions = EmberVersionFetcher.run

    ember_versions.each do |version_data|
      tag_name = version_data['tag_name']
      ember_version = EmberVersion.find_by(version: tag_name)

      next unless ember_version.nil?
      EmberVersion.create!(
        released: version_data['published_at'],
        version: tag_name
      )
    end
  end
end
