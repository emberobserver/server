# frozen_string_literal: true

namespace :search do
  task prepare: %i[ensure_directory fetch_source index]

  task ensure_directory: :environment do
    code_index_dir = ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
    unless File.exist?(code_index_dir)
      FileUtils.mkdir_p code_index_dir
    end
  end

  task fetch_source: :environment do
    code_index_dir = ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
    code_copy_dir = ENV['FULL_SOURCE_DIR'] || File.join(Rails.root, 'source-copy')
    addons_to_fetch = Addon.with_valid_repo
    puts "Fetching source for #{addons_to_fetch.size} addons..."
    addons_to_fetch.select(:id).each do |addon|
      AddonSourceUpdater.new(addon.id, full_source_dir: code_copy_dir, indexed_source_dir: code_index_dir).run
    end

    all_addon_directories = Dir.entries(code_index_dir)
    all_indexed_addons = addons_to_fetch.select(:id).all.map { |a| a.id.to_s }

    directories_to_clean_up = all_addon_directories - all_indexed_addons - ['.', '..']
    directories_to_clean_up.each do |dir|
      FileUtils.rm_rf File.join(code_index_dir, dir)
    end
  end

  task index: :environment do
    code_index_dir = ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
    index_cmd = "/usr/local/bin/cindex #{code_index_dir}"
    puts "Running '#{index_cmd}'..."
    `#{index_cmd}`
    puts 'Done indexing!'
  end

  task remove: :environment do
    code_index_dir = ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
    puts "Removing source directory at #{code_index_dir}"
    FileUtils.rm_rf code_index_dir
  end
end
