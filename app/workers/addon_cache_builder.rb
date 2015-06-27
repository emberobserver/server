class AddonCacheBuilder
	include Sidekiq::Worker

	def perform
		Rails.cache.write 'api:addons:index', build_json
	end

	def build_json
		addons = Addon.includes(:maintainers).includes(:addon_versions).where(hidden: false).all
		ActiveModel::ArraySerializer.new(addons, { each_serializer: AddonSerializer, root: 'addons' }).to_json
	end
end
