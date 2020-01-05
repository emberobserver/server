server 'emberobserver.com', user: 'eo', roles: %w{web app db redis}
set :rails_env, :production
set :rvm_ruby_version, '2.5.0'

set :nvm_type, :system
set :nvm_node, 'v12.14.0'
set :nvm_map_bins, %w{node npm yarn}