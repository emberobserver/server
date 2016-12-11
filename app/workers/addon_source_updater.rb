class AddonSourceUpdater < ActiveJob::Base

  def perform(addon_id)
    fetch_or_clone_repo(addon_id)
  end

  private

  def code_index_dir
    ENV['INDEX_SOURCE_DIR'] || File.join(Rails.root, 'source')
  end

  def fetch_or_clone_repo(addon_id)
    addon = Addon.find(addon_id)
    addon_source_dir = File.join(code_index_dir, addon.name)

    if File.exist?(addon_source_dir)
      update_addon(addon, addon_source_dir)
    else
      clone_addon(addon)
    end
  end

  def update_addon(addon, addon_source_dir)
    FileUtils.cd(addon_source_dir) do
      puts "Updating #{addon.name}..."
      pull_command = 'GIT_TERMINAL_PROMPT=0 git pull'
      unless system(pull_command)
        puts "Source for #{addon.name} no longer available, removing directory"
        FileUtils.rm_rf(addon_source_dir)
      end
    end
  end

  def clone_addon(addon)
    FileUtils.cd(code_index_dir) do
      puts "Cloning #{addon.name}..."
      clone_command = "GIT_TERMINAL_PROMPT=0 git clone --single-branch #{addon.repository_url} #{addon.name}"
      unless system(clone_command)
        puts "Source for #{addon.name} is not available, skipping"
      end
    end
  end
end
