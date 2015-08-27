class MaintainerCacheBuilder < ActiveJob::Base
	def perform
		Rails.cache.write 'api:maintainers:index', build_json
	end

	def build_json
		maintainers = NpmMaintainer.includes(:addons).all
		ActiveModel::ArraySerializer.new(maintainers, { each_serializer: NpmMaintainerSerializer, root: 'maintainers' }).to_json
	end
end
