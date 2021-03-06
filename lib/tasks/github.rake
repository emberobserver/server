# frozen_string_literal: true

namespace :github do
  task setup_octokit: :environment do
    unless ENV['GITHUB_ACCESS_TOKEN']
      puts 'Environment variable GITHUB_ACCESS_TOKEN not set!'
    end

    stack = Faraday::RackBuilder.new do |builder|
      builder.use Faraday::HttpCache, store: Rails.cache
      builder.use Octokit::Response::RaiseError
      builder.use FaradayMiddleware::FollowRedirects, limit: 3
      builder.adapter Faraday.default_adapter
    end
    Octokit.middleware = stack
    Octokit.auto_paginate = true

    @github = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
  end

  namespace :update do
    task all: [:setup_octokit, :environment] do
      begin
        hour = Time.current.hour % 12
        Addon.where('github_user is not null').where('github_repo is not null').where(has_invalid_github_repo: false).each do |addon|
          addon_updated_since_last_github_fetch = (addon.latest_version_date > addon.repo_info_last_updated_at) if addon.latest_version_date && addon.repo_info_last_updated_at
          addon_scheduled_to_be_updated = (addon.id % 12 == hour)
          if addon_scheduled_to_be_updated || addon_updated_since_last_github_fetch
            update_github_data(addon)
          end
        end
      rescue Octokit::TooManyRequests
        puts "WARN: Github API limit exceeded"
      end
    end
  end

  task :update, [:name] => [:setup_octokit, :environment] do |_, args|
    addon = Addon.find_by(name: args[:name])
    if addon
      update_github_data(addon)
    else
      puts "Invalid addon '#{args[:name]}'"
    end
  end
end

def update_github_data(addon)
  user = addon.github_user
  repo = addon.github_repo.sub(/#.+?$/, '')
  slug = "#{user}/#{repo}"

  github_stats = addon.github_stats || GithubStats.new(addon_id: addon.id)

  begin
    data = @github.repo(slug)
    github_stats.open_issues = data.open_issues_count || 0
    github_stats.forks = data.forks_count || 0
    github_stats.stars = data.stargazers_count || 0
    github_stats.repo_created_date = data.created_at || 0

    contributors = remove_dummy_contributors(@github.contributors(slug))
    github_stats.contributors = contributors.length
    unless contributors.empty?
      addon.github_contributors.clear
      contributors.each do |contributor|
        github_user = GithubUser.find_or_create_by(login: contributor.login)
        github_user.avatar_url = contributor.avatar_url
        github_user.save
        addon.github_contributors << github_user
      end
    end

    commits = @github.commits(slug).to_a
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
    addon.repo_info_last_updated_at = Time.current
    addon.save
  rescue Octokit::BadGateway, Octokit::Conflict, Octokit::InternalServerError, Octokit::ServiceUnavailable, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, Net::OpenTimeout
    puts "WARN: Temporarily unable to update data for #{addon.name}"
  rescue Octokit::NotFound, URI::InvalidURIError
    puts "WARN: Addon #{addon.name} has invalid Github data"
    addon.has_invalid_github_repo = true
    addon.save
  end
end

def remove_dummy_contributors(contributors)
  dummy_contributors = ['ember-tomster', 'travis-ci-ciena', 'greenkeeperio-bot']
  unless contributors.respond_to?(:reject)
    return []
  end
  contributors.reject { |contributor| dummy_contributors.include?(contributor.login) }
end
