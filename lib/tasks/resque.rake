require 'resque/tasks'
require Rails.root.join('app/workers/resque_seo_filters_update.rb').to_s

task "resque:setup" => :environment do
	ENV['QUEUE'] = '*'
end