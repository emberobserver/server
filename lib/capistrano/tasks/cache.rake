namespace :cache do
	desc "Clear /api/addons cache"
	task :clear do
		on roles(:redis) do
			run "redis-cli DEL api:addons:index"
		end
	end
end
