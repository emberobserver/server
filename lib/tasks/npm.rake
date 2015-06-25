namespace :npm do
  task fetch: :environment do
    sh 'node ./npm-fetch/fetch.js'
  end

  task fetch_addon_info: [ 'npm:update' ] do
    if Rails.env.production?
      snitch_url = ENV['FETCH_SNITCH_URL']
      sh "curl #{snitch_url}"
    end
  end

  task update: [ :environment, 'npm:fetch' ] do
    begin
      addons = ActiveSupport::JSON.decode(File.read('/tmp/addons.json'))
    rescue ActiveSupport::JSON.parse_error
      raise "Invalid JSON in addons.json file"
    end

    addons.each do |metadata|
      create_or_update_addon(metadata)
    end
  end

  task fetch_downloads: :environment do
    addon_names = Addon.pluck(:name)
    File.open('/tmp/addon-names.json', 'w') do |file|
      file << addon_names.to_json
    end
   sh 'node ./npm-fetch/historical-downloads.js'
  end

  task import_downloads: [ :environment, 'npm:fetch_downloads' ] do
    begin
      data = ActiveSupport::JSON.decode(File.read("/tmp/addon-downloads.json"))
    rescue ActiveSupport::JSON.parse_error
      raise "Invalid JSON in addon-downloads.json"
    end

    data.each do |download_data|
      next unless download_data.include?('package')
      addon = Addon.where(name: download_data['package']).first
      next unless addon
      download_data['downloads'].each do |downloads|
        addon_downloads = addon.downloads.find_or_create_by(date: downloads['day'])
        addon_downloads.downloads = downloads['downloads']
        addon_downloads.save
      end
    end
  end
end

def autohide?(addon)
  addon.name =~ /fill-murray/ && addon.name != 'ember-cli-fill-murray'
end

def demo_url(addon_data)
  ember_addon_info = addon_data['latest']['ember-addon']
  return nil if ember_addon_info.nil?
  demo_url = ember_addon_info['demoURL']
  if demo_url.nil? || demo_url !~ /^http/
    return nil
  end
  demo_url
end

def repo_url(url)
  if url =~ /git@github.com/
    url.sub!('git@github.com', 'github.com')
  end
  if url =~ %r|^git\+https://github.com|
    url.sub!(/^git\+/, '')
  elsif url =~ %r|^git\+ssh://github.com|
    url.sub!(/^git\+ssh/, 'https')
  end
  url
end

def create_or_update_addon(metadata)
  name = metadata['name']

  addon = Addon.find_or_initialize_by(name: name)
  latest_version = metadata['latest']['version']
  addon_props = {
    demo_url: demo_url(metadata),
    description: metadata['description'],
    latest_version: latest_version,
    latest_version_date: metadata['time'] ? metadata['time'][ latest_version ] : nil,
    license: metadata['license'],
    published_date: metadata['created'],
    repository_url: repo_url(metadata['repository']['url'])
  }
  if metadata.include?('github')
    github_data = metadata['github']
    if github_data['user'] && github_data['repo']
      addon_props[:github_user] = github_data['user']
      addon_props[:github_repo] = github_data['repo']
    elsif github_data['repo'].nil? && github_data['user'] =~ %r{^http://www\.github\.com/(.+?)/(.+?)\.git}
      addon_props[:github_user] = $1
      addon_props[:github_repo] = $2
    end
  end
  addon.update(addon_props)

  if metadata['downloads']['start']
    addon_downloads = addon.downloads.find_or_create_by(date: metadata['downloads']['start'])
    addon_downloads.downloads = metadata['downloads']['downloads']
    addon_downloads.save
  end

  npm_author = metadata['author']
  if npm_author
    author = NpmAuthor.find_or_create_by(name: npm_author['name'], email: npm_author['email'])
    author.url = npm_author['url']
    if author != addon.author
      addon.author = author
    end
    author.save
  else
    addon.author = nil
  end

  addon.npm_keywords.clear
  metadata['keywords'].each do |keyword|
    npm_keyword = NpmKeyword.find_or_create_by(keyword: keyword)
    addon.npm_keywords << npm_keyword
  end

  addon.maintainers.clear
  metadata['maintainers'].each do |maintainer|
    npm_user = NpmMaintainer.find_or_create_by(name: maintainer['name'], email: maintainer['email'])
    if maintainer['gravatar_id']
      npm_user.gravatar = maintainer['gravatar_id']
      npm_user.save
    end
    addon.maintainers << npm_user
  end

  current_versions = metadata['versions'].keys
  addon.addon_versions = AddonVersion.where(addon_id: addon.id, version: current_versions)

  metadata['versions'].each do |version, data|
    addon_version = addon.addon_versions.where(version: version).first
    if addon_version && data['devDependencies'] && data['devDependencies']['ember-cli'] && !addon_version.ember_cli_version
      addon_version.ember_cli_version = data['devDependencies']['ember-cli']
      addon_version.save
    end
    unless addon_version
      new_addon_version = AddonVersion.find_or_create_by(
        addon: addon,
        version: version,
        released: metadata['time'][version],
        ember_cli_version: (data['devDependencies'] ? data['devDependencies']['ember-cli'] : nil)
      )
      addon.addon_versions << new_addon_version
    end
  end

  addon.last_seen_in_npm = DateTime.now
  if autohide?(addon)
    addon.hidden = true
  end
  addon.save!
end
