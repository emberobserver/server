namespace :npm do
  task fetch: :environment do
    sh 'node ./npm-fetch/fetch.js'
  end

  task update: [ :environment, 'npm:fetch' ] do
    begin
      addons = ActiveSupport::JSON.decode(File.read('/tmp/addons.json'))
    rescue ActiveSupport::JSON.parse_error
      raise "Invalid JSON in addons.json file"
    end

    addons.each do |metadata|
      name = metadata['name']

      addon = Addon.find_or_initialize_by(name: name)
      latest_version = metadata['latest']['version']
      addon.update(
        latest_version: latest_version,
        latest_version_date: metadata['time'] ? metadata['time'][ latest_version ] : nil,
        description: metadata['description'],
        license: metadata['license'],
        repository_url: metadata['repository']['url']
      )

      npm_author = metadata['author']
      if npm_author
        author = NpmUser.find_or_create_by(name: npm_author['name'], email: npm_author['email'])
        if author != addon.author
          addon.author = author
        end
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
        npm_user = NpmUser.find_or_create_by(name: maintainer['name'], email: maintainer['email'])
        addon.maintainers << npm_user
      end

      addon.addon_versions.clear
      metadata['versions'].each do |version, data|
        addon_version = AddonVersion.where(
          addon_id: addon.id,
          version: version
        ).first
        unless addon_version
          addon_version = addon.addon_versions.create(
            version: version,
            released: metadata['time'][version]
          )
        end
        addon.addon_versions << addon_version
      end

      addon.save!
    end
  end
end
