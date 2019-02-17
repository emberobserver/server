# frozen_string_literal: true

class AddonSourceUpdater
  EXCLUDED = %w[/bower_components /node_modules /tmp /dist /vendor /public /coverage /tests/fixtures /demo
                /typings /website /docs /support /dependencies /jsdocTemplates /test/vendor /example /examples
                /.git npm-shrinkwrap.json dependency-snapshot.json .gitkeep bin/ .bin/ **/*.log **/yarn.lock **/Gemfile.lock].freeze

  def initialize(addon_id, directories)
    @source_directory = directories[:full_source_dir]
    @source_directory_to_index = directories[:indexed_source_dir]
    @addon = Addon.find(addon_id)

    @addon_directory = File.join(@source_directory, addon.id.to_s)
    @addon_directory_to_index = File.join(@source_directory_to_index, addon.id.to_s)
  end

  def run
    fetch_or_clone_repo
    copy_to_indexed_directory
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
        FileUtils.rm_rf(addon_directory)
      end
    end
  end

  def copy_to_indexed_directory
    if File.exist?(addon_directory)
      excludes = EXCLUDED.map { |e| "--exclude=#{e}" }.join(' ')
      # copy, e.g. /source-dir/addon-name/ /dest-dir/addon-name/
      # done with trailing slashes so the excludes starting with a / are matched at the root of the transfer
      system("rsync -az --delete-before --delete-excluded #{excludes} #{addon_directory}/ #{addon_directory_to_index}/")
    else
      FileUtils.rm_rf(addon_directory_to_index)
    end
  end

  attr_reader :source_directory, :source_directory_to_index, :addon_directory, :addon_directory_to_index, :addon
end
