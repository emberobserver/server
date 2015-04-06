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
		task all: [ 'cache:clear:addons', 'cache:clear:categories' ]
	end

	namespace :prime do
		desc "Prime the /api/addons cache"
		task addons: :environment do
			ActionDispatch::Integration::Session.new(Rails.application).get('/api/addons')
		end

		desc "Prime the /api/categories cache"
		task categories: :environment do
			ActionDispatch::Integration::Session.new(Rails.application).get('/api/categories')
		end

		desc "Prime all caches"
		task all: [ 'cache:prime:addons', 'cache:prime:categories' ]
	end

	desc "Clear and prime all caches"
	task reset: [ 'cache:clear:all', 'cache:prime:all' ]
end
