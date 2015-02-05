# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'ember-addon-review-server'
set :repo_url, 'git@github.com:kategengler/ember-addon-review-server.git'

set :deploy_to, '/srv/app/ember-addon-review/server'

set :linked_files, %w{ .env }
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

set :ssh_options, { forward_agent: true }

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
