class AddonScoreUpdater < ActiveJob::Base

	def perform(addon_id)
		addon = Addon.find(addon_id)
		update_score(addon)
		update_badge(addon)
	end

	private

	def update_score(addon)
		addon.score = AddonScoreCalculator.calculate_score(addon)
		addon.save
	end

	def update_badge(addon)
		score = 'na'
		if addon.is_wip
			score = 'wip'
		else
			score = addon.score || 'na'
		end

		addon_badge_dir = ENV['ADDON_BADGE_DIR'] || File.join(Rails.root, "public/badges")
		badge_image_path = File.join(Rails.root, "app/assets/images/badges/#{score}.svg")
		badge_image_name = File.join(addon_badge_dir, "#{safe_name addon.name}.svg")
		FileUtils.copy badge_image_path, badge_image_name
		File.chmod 0644, badge_image_name
	end

	def safe_name(name)
		name.gsub(/[^A-Za-z0-9]/, '-')
	end
end
