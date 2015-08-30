class AddonCacheBuilder < ActiveJob::Base
	def perform
		Rails.cache.write 'api:addons:index', build_json
	end

	def build_json
		addons = Addon.where(hidden: false).includes(:addon_versions).includes(:reviews).all
		ActiveModel::ArraySerializer.new(addons, { each_serializer: SimpleAddonSerializer, root: 'addons' }).to_json
	end
end
