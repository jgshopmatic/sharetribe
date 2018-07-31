require "mina/rails"
require "mina/git"
require "mina/rbenv"  # for rbenv support. (https://rbenv.org)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, "sharetribe"
set :domain, "dev.goshopmatic.com"
set :deploy_to, "/home/gaurav/app/sharetribe"
set :repository, "git@github.com:jgshopmatic/sharetribe.git"
set :branch, "dev"

# Optional settings:
set :user, "jidesh"          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push("public/assets", "public/system", "log", "tmp")
set :shared_files, fetch(:shared_files, []).push("config/database.yml", "config/secrets.yml", "config/config.yml")

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %{rbenv install 2.5.1 --skip-existing}
  command %{eval "$(ssh-agent -s)"}
  command %{ssh-add ~/.ssh/sharetribe}
  command %{export RAILS_ENV=production}
  command %{export NODE_ENV=production}
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    command %{npm install --force }
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        #        command %{bundle exec rake ts:index}
        #        command %{bundle exec rake ts:start}
        command %{kill -9 `pgrep -f 'sphinx'` > /dev/null 2> /dev/null || :}
        command %{kill -9 `pgrep -f 'rake jobs:work'` > /dev/null 2> /dev/null || :}
        command %{passenger-config restart-app $(pwd) }
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        #command %{pushd "/home/gaurav/app/sharetribe/current"}
        #

      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task :index do
  command %{pushd "/home/gaurav/app/sharetribe/current"}
  command %{bundle exec rake ts:index}
  command %{echo "indexing done"}
end

task :ts do
  command %{pushd "/home/gaurav/app/sharetribe/current"}
  command %{echo `nohup bundle exec rake ts:start > /home/gaurav/app/sharetribe/log/ts.log 2>&1 & sleep 5`}
  command %{echo "ts started"}
end

task :jobs do
  command %{pushd "/home/gaurav/app/sharetribe/current"}
  command %{echo `nohup bundle exec rake jobs:work > /home/gaurav/app/sharetribe/log/jobs.log 2>&1 & sleep 5`}
  command %{echo "jobs started"}
end
