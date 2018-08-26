# frozen_string_literal: true
require 'pty'
require 'expect'

class AddonInstaller
  INSTALL_DIR = 'ember-new-output'
  BASE_JSON_FILE = Rails.root.join(INSTALL_DIR, 'base-size.json')
  ADDON_JSON_FILE = Rails.root.join(INSTALL_DIR, 'with-addon-size.json')

  def self.base_size_filename
    BASE_JSON_FILE
  end

  def self.addon_size_filename
    ADDON_JSON_FILE
  end

  def self.install_dir
    INSTALL_DIR
  end

  def self.install_ember_new
    FileUtils.rmtree 'ember-new-output'
    system('git clone git@github.com:ember-cli/ember-new-output.git -b stable')
    FileUtils.cd INSTALL_DIR do
      system('yarn')
      system('git add -A && git commit -m "yarn install"')
      system("ember build --environment=production && ember asset-sizes --json > #{BASE_JSON_FILE}")
    end

  end

  def self.install_addon(addon_version)
    FileUtils.cd INSTALL_DIR do
      current_sha = `git rev-parse HEAD`
      begin
        system("yarn add #{addon_version.addon_name} --dev -v #{addon_version.version}")
        # system("ember install #{addon_name}") sometimes hangs on blueprint confirmation prompts
        system("ember build --environment=production && ember asset-sizes --json > #{ADDON_JSON_FILE}")
      ensure
        system("git reset --hard #{current_sha}")
      end
    end
  end

  def self.cleanup
    system("rm -rf #{INSTALL_DIR}")
  end
end
