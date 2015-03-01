namespace :addons do
	desc "Update download count for addons"
	task update_download_count: :environment do
		Addon.all.each do |addon|
			addon.last_month_downloads = addon.downloads.where('date > ?', 1.month.ago).sum(:downloads)
			addon.save
		end
	end

	desc "Update 'top 10%' flag for addon downloads"
	task update_downloads_flag: [ :environment, 'addons:update_download_count' ] do
		total_addons = Addon.count
		Addon.order('last_month_downloads desc').each_with_index do |addon, index|
			if (index + 1).to_f / total_addons <= 0.1
				addon.is_top_downloaded = true
			else
				addon.is_top_downloaded = false
			end
			addon.save
		end
	end
end
