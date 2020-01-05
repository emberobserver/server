# frozen_string_literal: true

require 'open3'

class Linter
  attr_reader :addon

  def initialize(addon)
    @addon = addon
  end

  def run(run_lint = run_lint_command)
    unless File.exist?(addon_source_dir)
      raise "Source not found for #{addon.name}"
    end

    stdout, stderr, = run_lint

    unless stderr.empty?
      Rails.logger.error(stderr)
      raise "Error linting #{addon.name}"
    end

    output = JSON.parse(stdout)
    output.map do |o|
      {
        filePath: o['filePath'].gsub("#{addon_source_dir}/", ''),
        messages: o['messages'],
        errorCount: o['errorCount'],
        warningCount: o['warningCount']
      }
    end
  end

  def sha
    output, = Open3.capture3('git', 'rev-parse', '--short', 'HEAD', chdir: addon_source_dir)
    @sha ||= output.delete("\n")
  end

  private

  LINTING_DIR = File.join(Rails.root, 'linting')
  LINT_CONFIG = File.join(LINTING_DIR, 'static-eslintrc.js')

  def run_lint_command
    Open3.capture3('npx', 'eslint', '--no-eslintrc', '-c', LINT_CONFIG, '--no-ignore', '--no-inline-config', '--quiet', '-f', 'json', "#{addon_source_dir}/{addon,app}/**/*.js", chdir: LINTING_DIR)
  end

  def source_dir
    @source_dir ||= ENV['FULL_SOURCE_DIR'] || File.join(Rails.root, 'source-copy')
  end

  def addon_source_dir
    @addon_dir ||= File.join(source_dir, addon.id.to_s)
  end
end
