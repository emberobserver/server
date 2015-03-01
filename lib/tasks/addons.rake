namespace :addons do
	desc "Update download count for addons"
	task update_download_count: :environment do
		Addon.all.each do |addon|
			addon.last_month_downloads = addon.downloads.where('date > ?', 1.month.ago).sum(:downloads)
			addon.save
		end
	end
end
