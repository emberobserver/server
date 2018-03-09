# frozen_string_literal: true

class AddonSourceUpdater < ApplicationJob
  EXCLUDED_PATHS = %w[bower_components node_modules tmp dist vendor public coverage tests/fixtures demo
                      typings website docs support dependencies jsdocTemplates test/vendor example examples
                      npm-shrinkwrap.json dependency-snapshot.json].freeze
  EXCLUDED_PATTERNS = %w[**/*.log **/yarn.lock **/Gemfile.lock].freeze

  def perform(addon_id, source_directory)
    @source_directory = source_directory
    @addon = Addon.find(addon_id)
    @addon_directory = File.join(source_directory, addon.id.to_s)
    fetch_or_clone_repo
    remove_excluded_paths
  end

  private

  def fetch_or_clone_repo
    if File.exist?(addon_directory)
      update_addon
    else
      clone_addon
    end
  end

  def update_addon
    FileUtils.cd(addon_directory) do
      puts "Updating #{addon.name} into '#{addon.id}'..."
      system('git reset --hard HEAD')
      pull_command = 'GIT_TERMINAL_PROMPT=0 git pull'
      unless system(pull_command)
        puts "Source for #{addon.name} no longer available, removing directory"
        FileUtils.rm_rf(addon_directory)
      end
    end
  end

  def clone_addon
    FileUtils.cd(source_directory) do
      puts "Cloning #{addon.name}..."
      clone_command = "GIT_TERMINAL_PROMPT=0 git clone --single-branch #{addon.repository_url} #{addon.id}"
      unless system(clone_command)
        puts "Source for #{addon.name} is not available, skipping"
      end
    end
  end

  def remove_excluded_paths
    return unless File.exist?(addon_directory)
    FileUtils.cd addon_directory do
      FileUtils.rmtree EXCLUDED_PATHS
      EXCLUDED_PATTERNS.each { |pattern| FileUtils.rmtree Dir.glob(pattern) }
    end
  end

  attr_reader :source_directory, :addon_directory, :addon
end
