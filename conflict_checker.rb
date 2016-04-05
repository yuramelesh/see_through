#!/usr/bin/env ruby
require_relative 'config/config_reader'
require_relative 'octokit_client'
require_relative 'main_controller'

class ConflictChecker

  def initialize

    @repo
    @repositories = Config_reader.new.get_repos
    @client = OctokitClient.new
    @controller = MainController.new

    start

  end

  def start
    @repositories.each do |repo|
      @repo = repo.repository_name

      github_pull_requests = @client.get_all_github_pr @repo
      db_pull_requests = @controller.get_all_pr

      github_pr_numbers = [].to_set
      db_pr_numbers = [].to_set

      if github_pull_requests != nil
        github_pull_requests.each do |git_nub_pr|
          github_pr_numbers.add(git_nub_pr['number'])
        end
        db_pull_requests.each do |db_pr|
          db_pr_numbers.add(db_pr[:pr_id].to_i)
        end
        different = db_pr_numbers ^ github_pr_numbers
        check_pull_requests_state different
      end
    end
  end

  def check_pull_requests_state pull_requests
    pull_requests.each do |pr|
      db_request = @controller.get_pr_by_id pr
      db_request.each do |db_item|
        puts 'pr # ' + db_item.pr_id
        puts 'state in db ' + db_item.state
        github_request = @client.get_github_pr_by_number @repo, pr
        if github_request.merged == true
          puts "merged: #{github_request.merged}"
        else
          puts 'merged: false'
        end
        puts '---------------------------------------------------'
      end
    end
  end

end

ConflictChecker.new
