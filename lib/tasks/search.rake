namespace :search do
  task prepare: [:ensure_directory, :fetch_source, :index]

  task :ensure_directory do
    code_index_dir = ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
    unless File.exist?(code_index_dir)
      FileUtils.mkdir_p code_index_dir
    end
  end

  task fetch_source: :environment do
    addons_to_fetch = Addon.where(has_invalid_github_repo: false).where.not(repository_url: nil, github_repo: nil)
    addons_to_fetch.select(:id).each do |addon|
      AddonSourceUpdater.perform_now(addon.id)
    end
  end

  task :index do
    code_index_dir = ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
    index_cmd = "cindex #{code_index_dir}"
    puts "Running '#{index_cmd}'..."
    `#{index_cmd}`
    puts 'Done indexing!'
  end

  task :remove do
    code_index_dir = ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
    puts "Removing source directory at #{code_index_dir}"
    FileUtils.rm_rf code_index_dir
  end
end
