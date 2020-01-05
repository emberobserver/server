# frozen_string_literal: true

namespace :deploy do
  namespace :linting do
    desc 'Install Node packages for linting, using yarn'
    task :yarn_install do
      on roles(:app) do
        within "#{release_path}/linting" do
          execute :yarn, 'install'
        end
      end
    end
  end
end
