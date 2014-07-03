set :application, 'DingBa'
set :repo_url, 'ssh://deploy@beta.streams.tw/~/git/DingBa.git'

set :deploy_to, '/home/deploy/DingBa'

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

set :scm, "git"
set :rails_env, "production"

set :deploy_via, :remote_cache

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      #execute  "cd /home/deploy/HiWorks/current/; rake assets:precompile RAILS_ENV=production" 	
      #execute  "/root/ruby/nginx/sbin/nginx -s reload"		
    end
  end

  task :copyResToTemp do
    on roles(:app), in: :sequence, wait: 5 do
      execute  "mv /home/deploy/DingBa/current/public/res /home/deploy/DingBa/shared/res  " 	
      
    end
  end

  task :copyResToProduction do
    on roles(:app), in: :sequence, wait: 5 do
      execute  "mv /home/deploy/DingBa/shared/res /home/deploy/DingBa/current/public/res   " 	
      
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  before :starting, 'deploy:copyResToTemp'
  before :finishing, 'deploy:copyResToProduction'
  after :finishing, 'deploy:cleanup'

end
