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

	desc "Update 'top 10%' flag for Github stars"
	task update_stars_flag: :environment do
		addons_with_stars = Addon.includes(:github_stats).references(:github_stats).where('github_stats.addon_id is not null and stars is not null')
		total_addons_with_stars = addons_with_stars.count
		Addon.includes(:github_stats).references(:github_stats).where('github_stats.addon_id is null or stars is null').each do |addon|
			addon.is_top_starred = false
			addon.save
		end
		addons_with_stars.order('stars desc').each_with_index do |addon, index|
			if (index + 1).to_f / total_addons_with_stars <= 0.1
				addon.is_top_starred = true
			else
				addon.is_top_starred = false
			end
			addon.save
		end
	end
end
