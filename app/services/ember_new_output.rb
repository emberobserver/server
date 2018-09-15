# frozen_string_literal: true

class EmberNewOutput
  INSTALL_DIR = 'ember-new-output'
  BASE_JSON_FILE = Rails.root.join(INSTALL_DIR, 'base-size.json')
  ADDON_JSON_FILE = Rails.root.join(INSTALL_DIR, 'with-addon-size.json')

  def self.install(install_dir = INSTALL_DIR)
    ember_new_output = new(install_dir)
    ember_new_output.install_and_measure
    ember_new_output
  end

  def initialize(install_dir)
    @install_dir = install_dir
  end

  def install_and_measure
    FileUtils.rmtree install_dir
    system('git clone git@github.com:ember-cli/ember-new-output.git -b stable')
    FileUtils.cd install_dir do
      system('yarn --silent --no-progress')
      system('rm .gitignore && git add -A && git commit -m "yarn install"')
      @current_sha = `git rev-parse HEAD`
      system("ember build --environment=production && ember asset-sizes --json > #{BASE_JSON_FILE}")
      @base_asset_sizes = parse_json_file(BASE_JSON_FILE)
      system("rm -rf dist/ tmp/ #{BASE_JSON_FILE}")
    end
  end

  def install_addon_and_measure(addon_version)
    FileUtils.cd install_dir do
      system("yarn add #{addon_version.addon_name}@#{addon_version.version} --dev --no-progress")
      # system("ember install #{addon_name}") sometimes hangs on blueprint confirmation prompts
      system("ember build --environment=production && ember asset-sizes --json > #{ADDON_JSON_FILE}")
      asset_sizes_with_addon = parse_json_file(ADDON_JSON_FILE)
      generate_diff(asset_sizes_with_addon)
    ensure
      system("rm -rf dist/ tmp/ #{ADDON_JSON_FILE}")
      system("git add -A && git reset --hard #{current_sha}")
    end
  end

  def parse_json_file(file_name)
    file_contents = File.read(file_name)
    file_parser = AssetSizeParser.new(file_contents)
    file_parser.asset_size_json
  end

  def generate_diff(base_plus_addon_size_data)
    AddonSizeDiff.new(base_asset_sizes, base_plus_addon_size_data)
  end

  def cleanup
    system("rm -rf #{install_dir}")
  end

  private

  attr_accessor :install_dir, :current_sha, :base_asset_sizes
end
