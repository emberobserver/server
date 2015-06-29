class CategoryCacheBuilder < ActiveJob::Base

	def perform
		Rails.cache.write 'api:categories:index', build_json
	end

	def build_json
		categories = Category.includes(:addons)
		ActiveModel::ArraySerializer.new(categories, { each_serializer: CategorySerializer, root: 'categories' }).to_json
	end
end
