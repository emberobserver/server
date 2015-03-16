namespace :addons do
	namespace :update do
		desc "Update download count for addons"
		task download_count: :environment do
			Addon.all.each do |addon|
				addon.last_month_downloads = addon.downloads.where('date > ?', 1.month.ago).sum(:downloads)
				addon.save
			end
		end

		desc "Update 'top 10%' flag for addon downloads"
		task downloads_flag: [ :environment, 'addons:update_download_count' ] do
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
		task stars_flag: :environment do
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

		desc "Update scores for addons"
		task scores: :environment do
			addon_badge_dir = ENV['ADDON_BADGE_DIR'] || File.join(Rails.root, "public/badges")
			Addon.all.each do |addon|
				score = 0
				review = addon.newest_review
				if review
					score = score + 1 if review.has_tests == 1
					score = score + 1 if review.has_readme == 1
					score = score + 1 if review.is_more_than_empty_addon == 1
					score = score + 1 if review.is_open_source == 1
					score = score + 1 if review.has_build == 1
				end
				score = score + 1 if addon.recently_released?
				score = score + 1 if addon.recently_committed_to?
				score = score + 1 if addon.is_top_downloaded
				score = score + 1 if addon.is_top_starred
				score = score + 1 if addon.github_contributors.length > 1

				unless addon.newest_review
					score = nil
				end
				addon.score = score
				addon.save

				score = score || 'na'
				badge_image_path = File.join(Rails.root, "app/assets/images/badges/#{score}.svg")
				cp badge_image_path, File.join(addon_badge_dir, "#{safe_name addon.name}.svg")
			end

			Rake::Task['cache:clear:all'].invoke
		end

		desc "Update all data for addons"
		task all: [ :environment, 'npm:fetch_addon_info', 'github:update_data', 'addons:update_downloads_flag', 'addons:update_stars_flag', 'addons:update_scores' ]
	end
end

def safe_name(name)
	name.gsub(/[^A-Za-z0-9]/, '-')
end
