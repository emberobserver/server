class AddonSourceUpdater < ActiveJob::Base
  EXCLUDED_DIRS = %w(bower_components node_modules tmp dist vendor public coverage tests/fixtures demo typings)

  def perform(addon_id, source_directory)
    @source_directory = source_directory
    @addon = Addon.find(addon_id)
    @addon_directory = File.join(source_directory, addon.name)

    fetch_or_clone_repo
    remove_excluded_directories
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
      puts "Updating #{addon.name}..."
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
      clone_command = "GIT_TERMINAL_PROMPT=0 git clone --single-branch #{addon.repository_url} #{addon.name}"
      unless system(clone_command)
        puts "Source for #{addon.name} is not available, skipping"
      end
    end
  end

  def remove_excluded_directories
    return unless File.exist?(addon_directory)
    FileUtils.cd addon_directory do
      FileUtils.rmtree EXCLUDED_DIRS
    end
  end

  attr_reader :source_directory, :addon_directory, :addon
end
