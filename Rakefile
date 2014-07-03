# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# =====================================================
#require 'resque/tasks'
#
#task "resque:setup" => :environment do
#  ENV['QUEUE'] ||= '*'
#  Resque.before_fork do
#    defined?(ActiveRecord::Base) and
#        ActiveRecord::Base.connection.disconnect!
#  end
#
#  Resque.after_fork do
#    defined?(ActiveRecord::Base) and
#        ActiveRecord::Base.establish_connection
#  end
#end
# =====================================================

DingBa::Application.load_tasks
