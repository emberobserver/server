# frozen_string_literal: true

class NpmAddonDataUpdater
  def initialize(metadata)
    @metadata = metadata

    name = @metadata['name']
    @addon = Addon.find_or_initialize_by(name: name)
  end

  def update
    return if @addon.removed_from_npm
    update_addon_data
    update_readme
    update_author
    update_keywords
    update_maintainers
    update_addon_versions
    update_last_seen
    update_hidden_flag
    update_latest_addon_version
    update_update_timestamp
    save_addon
    @addon
  end

  private

  def autohide?
    @addon.name =~ /fill-?murray/ && @addon.name != 'ember-cli-fill-murray'
  end

  def demo_url(latest_version)
    ember_addon_info = @metadata['versions'][latest_version]['ember-addon']
    return nil if ember_addon_info.nil?
    demo_url = ember_addon_info['demoURL']
    if demo_url.nil? || demo_url !~ /^http/
      return nil
    end
    demo_url
  end

  def repo_url(url)
    NpmDataSanitizer.repository_url(url)
  end

  def save_addon
    @addon.save!
  end

  # This is needed because sometimes NPM makes up crazy shit for data. In the instance
  # that led to this, it decided to give back the repo name as repo-name.git#repo-name,
  # which doesn't appear anywhere in the addon's package.json or README.
  def unmangle_github_data(str)
    str = str.split(/#/)[0]
    str.sub!(/\.git$/, '')
    str.sub(/`$/, '')
  end

  def update_addon_data
    latest_version = @metadata['dist-tags']['latest']
    repo = @metadata['repository'] ? @metadata['repository']['url'] : nil
    addon_props = {
      demo_url: demo_url(latest_version),
      description: @metadata['description'],
      latest_version: latest_version,
      latest_version_date: @metadata['time'] ? @metadata['time'][latest_version] : nil,
      license: @metadata['license'],
      published_date: @metadata['time']['created'],
      repository_url: repo_url(repo)
    }
    if @metadata.include?('github')
      github_data = @metadata['github']
      if github_data['user'] && github_data['repo']
        addon_props[:github_user] = unmangle_github_data(github_data['user'])
        addon_props[:github_repo] = unmangle_github_data(github_data['repo'])
      elsif github_data['repo'].nil? && github_data['user'] =~ %r{^http://www\.github\.com/(.+?)/(.+?)\.git}
        addon_props[:github_user] = Regexp.last_match(1)
        addon_props[:github_repo] = Regexp.last_match(2)
      end
    elsif repo_url(repo) =~ %r{https?://(www\.)?github\.com/(.+?)/(.+?)(/.+?)?(\.git)?$}
      addon_props[:github_user] = Regexp.last_match(2)
      addon_props[:github_repo] = Regexp.last_match(3)
    end
    @addon.update!(addon_props)
  end

  def update_readme
    if @metadata['readme']
      @addon.readme = Readme.new(contents: @metadata['readme'])
    end
  end

  def update_addon_versions
    current_versions = @metadata['versions'].keys
    @addon.addon_versions = AddonVersion.where(addon_id: @addon.id, version: current_versions)

    @metadata['versions'].each do |version, data|
      addon_version = @addon.addon_versions.find_by(version: version)
      if addon_version && data['devDependencies'] && data['devDependencies']['ember-cli'] && !addon_version.ember_cli_version
        addon_version.ember_cli_version = data['devDependencies']['ember-cli']
        addon_version.save!
      end
      next if addon_version
      addon_version = AddonVersion.create!(
        addon: @addon,
        version: version,
        released: @metadata['time'][version],
        ember_cli_version: (data['devDependencies'] ? data['devDependencies']['ember-cli'] : nil)
      )
      if ENV['ADDON_SIZES_ENABLED']
        PendingSizeCalculation.create!(addon_version: addon_version)
      end
      @addon.addon_versions << addon_version
      update_addon_version_dependencies(addon_version, data)
    end
  end

  def update_latest_addon_version
    latest_version = @metadata['dist-tags']['latest']
    @addon.latest_addon_version = @addon.addon_versions.find_by(version: latest_version)
  end

  def update_addon_version_compatibility(addon_version, addon_version_metadata)
    return unless addon_version_metadata.include?('ember-addon')
    return unless addon_version_metadata['ember-addon'].include?('versionCompatibility')

    addon_version.compatible_versions.clear

    addon_version_metadata['ember-addon']['versionCompatibility'].each do |package_name, package_version|
      version_compatibility = AddonVersionCompatibility.find_or_create_by(
        package: package_name,
        version: package_version
      )
      addon_version.compatible_versions << version_compatibility
    end
  end

  def update_addon_version_dependencies(addon_version, addon_version_metadata)
    %w[devDependencies dependencies optionalDependencies peerDependencies].each do |dependency_type|
      next unless addon_version_metadata[dependency_type]
      addon_version_metadata[dependency_type].each do |package_name, version|
        dependency = AddonVersionDependency.find_or_create_by(
          package: package_name,
          version: version,
          dependency_type: dependency_type,
          addon_version: addon_version
        )
        addon_version.all_dependencies << dependency
      end

      update_addon_version_compatibility(addon_version, addon_version_metadata)
    end
  end

  def update_author
    npm_author = @metadata['author']
    if npm_author
      author = NpmAuthor.find_or_create_by(name: npm_author['name'], email: npm_author['email'])
      author.url = npm_author['url']
      @addon.author = author
      author.save!
    else
      @addon.author = nil
    end
  end

  def update_hidden_flag
    if autohide?
      @addon.hidden = true
    end
  end

  def update_keywords
    @addon.npm_keywords.clear
    if @metadata['keywords']
      @metadata['keywords'].each do |keyword|
        npm_keyword = NpmKeyword.find_or_create_by(keyword: keyword)
        @addon.npm_keywords << npm_keyword
      end
    end
  end

  def update_last_seen
    @addon.last_seen_in_npm = DateTime.now
  end

  def update_maintainers
    @addon.maintainers.clear
    @metadata['maintainers'].each do |maintainer|
      npm_user = NpmMaintainer.find_or_create_by(name: maintainer['name'])
      npm_user.email = maintainer['email']
      if maintainer['gravatar_id']
        npm_user.gravatar = maintainer['gravatar_id']
      end
      npm_user.save!
      @addon.maintainers << npm_user
    end
  end

  def update_update_timestamp
    @addon.package_info_last_updated_at = Time.current
  end
end
