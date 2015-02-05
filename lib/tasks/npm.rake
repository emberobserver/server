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

    addons.each do |addon|
      name = addon['name']

      package = Package.find_or_initialize_by(name: name)
      latest_version = addon['latest']['version']
      package.update(
        latest_version: latest_version,
        latest_version_date: addon['time'] ? addon['time'][ latest_version ] : nil,
        description: addon['description'],
        license: addon['license'],
        repository_url: addon['repository']['url']
      )

      npm_author = addon['author']
      if npm_author
        author = NpmUser.find_or_create_by(name: npm_author['name'], email: npm_author['email'])
        if author != package.author
          package.author = author
        end
      else
        package.author = nil
      end

      package.npm_keywords.clear
      addon['keywords'].each do |keyword|
        npm_keyword = NpmKeyword.find_or_create_by(keyword: keyword)
        package.npm_keywords << npm_keyword
      end

      package.maintainers.clear
      addon['maintainers'].each do |maintainer|
        npm_user = NpmUser.find_or_create_by(name: maintainer['name'], email: maintainer['email'])
        package.maintainers << npm_user
      end

      package.package_versions.clear
      addon['versions'].each do |version, data|
        package_version = PackageVersion.find_or_create_by(
          package_id: package.id,
          version: version
        )
        package_version.released = addon['time'][version]
        package_version.save!
        package.package_versions << package_version
      end

      package.save!
    end
  end
end
