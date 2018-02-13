# frozen_string_literal: true

namespace :deploy do
  namespace :npm do
    desc 'Install NPM modules'
    task :install do
      on roles(:app) do
        within release_path do
          execute :npm, 'install'
        end
      end
    end
  end
end
