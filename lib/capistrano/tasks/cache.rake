namespace :cache do
	desc "Clear caches"
	task :clear do
		on roles(:redis) do
			within release_path do
				with rails_env: fetch(:rails_env) do
					execute :rake, "cache:regenerate:all"
				end
			end
		end
	end
end
