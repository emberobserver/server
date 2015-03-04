namespace :github do
	task update_data: :environment do
		github = Github.new(oauth_token: ENV['GITHUB_ACCESS_TOKEN'])
		Addon.where('github_user is not null').where('github_repo is not null').where(has_invalid_github_repo: false).each do |addon|
			user = addon.github_user
			repo = addon.github_repo.sub(/#.+?$/, '')

			github_stats = addon.github_stats || GithubStats.new(addon_id: addon.id)

			begin
				data = github.repos.get(user: user, repo: repo)
				github_stats.open_issues = data.open_issues_count
				github_stats.forks = data.forks_count
				github_stats.stars = data.stargazers_count
				github_stats.repo_created_date = data.created_at

				contributors = github.repos.stats.contributors(user: user, repo: repo)
				github_stats.contributors = contributors.length
				addon.github_contributors.clear
				contributors.each do |contributor|
					github_user = GithubUser.find_or_create_by(login: contributor.author.login)
					github_user.avatar_url = contributor.author.avatar_url
					github_user.save
					addon.github_contributors << github_user
				end

				commits = github.repos.commits.list(user: user, repo: repo, auto_pagination: true).to_a
				# Sort in descending date order
				commits.sort! { |a, b| b.commit.committer.date <=> a.commit.committer.date }

				github_stats.commits = commits.length
				if commits.last
					github_stats.first_commit_date = commits.last.commit.committer.date
					github_stats.first_commit_sha = commits.last.sha
				else
					github_stats.first_commit_date = nil
					github_stats.first_commit_sha = nil
				end
				if commits.second
					github_stats.penultimate_commit_date = commits.second.commit.committer.date
					github_stats.penultimate_commit_sha = commits.second.sha
				else
					github_stats.penultimate_commit_date = nil
					github_stats.penultimate_commit_sha = nil
				end
				if commits.first
					github_stats.latest_commit_date = commits.first.commit.committer.date
					github_stats.latest_commit_sha = commits.first.sha
				else
					github_stats.first_commit_date = nil
					github_stats.first_commit_sha = nil
				end

				github_stats.save
			rescue Github::Error::NotFound, URI::InvalidURIError
				puts "WARN: Addon #{addon.name} has invalid Github data"
			end
		end
	end
end
