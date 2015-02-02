namespace :npm do
  task update: :environment do
    system('nodejs ./npm-fetch/fetch.js');

    begin
      addons = ActiveSupport::JSON.decode(File.read('./addons.json'))

      addons.each do |addon|
        name = addon['latest']['name']

        package = Package.find_or_initialize_by(name: name)
        package.update!(
          latest_version: addon['latest']['version'],
          description: addon['latest']['description']
        )
      end
    rescue ActiveSupport::JSON.parse_error
      puts "Invalid json in file"
    end
  end
end
