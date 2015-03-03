require 'net/http'

namespace :cache do
	namespace :clear do
		desc "Clear the cache for /api/addons"
		task addons: :environment do
			Rails.cache.delete 'api:addons:index'
		end

		desc "Clear the cache for /api/categories"
		task categories: :environment do
			Rails.cache.delete 'api:categories:index'
		end

		desc "Clear all caches"
		task all: [ :environment, 'cache:clear:addons', 'cache:clear:categories' ]
	end

	namespace :prime do
		desc "Prime the /api/addons cache"
		task addons: :environment do
			include Rails.application.routes.url_helpers
			get addons_url(host: 'emberobserver.com')
		end

		desc "Prime the /api/categories cache"
		task categories: :environment do
			include Rails.application.routes.url_helpers
			get categories_url(host: 'emberobserver.com')
		end

		desc "Prime all caches"
		task all: [ 'cache:prime:addons', 'cache:prime:categories' ]
	end
end

def get(url)
	Net::HTTP.get(URI.parse(url))
end
