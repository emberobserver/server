namespace :cache do
	namespace :regenerate do
		desc "Regenerate the addons cache"
		task addons: :environment do
			AddonCacheBuilder.new.perform
		end

		desc "Regenerate the categories cache"
		task categories: :environment do
			CategoryCacheBuilder.new.perform
		end

		desc "Regenerate all caches"
		task all: [ 'cache:regenerate:addons', 'cache:regenerate:categories' ]
	end
end
