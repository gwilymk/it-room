task :update do
	`git update`
	`rake db:migrate RAILS_ENV=production`
	`touch tmp/restart.txt`
end

