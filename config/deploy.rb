# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'insales_seo'
set :deploy_user, 'mike'


set :scm, :git
set :repo_url, 'git@github.com:klishevich/insales_seo.git'
set :assets_roles, [:app]
set :keep_releases, 5
set :linked_files, %w{config/database.yml config/application.yml config/secrets.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :tests, []
set(:config_files, %w(
  unicorn_init.sh
  database.yml
  secrets.yml
  application.yml
))
set(:executable_config_files, %w(
  unicorn_init.sh
))

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :groups, limit: 3, wait: 10 do
      invoke 'unicorn:restart2'
    end
  end
  after 'deploy:publishing', 'deploy:restart'   

end

namespace :unicorn do

  desc 'Restart unicorn 2'
  task :restart2 do
    on roles(:app) do
      execute "/etc/init.d/unicorn_insales_seo restart"
    end
  end  

end

