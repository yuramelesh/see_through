#!/usr/bin/env ruby
require_relative 'config/config_reader'
require_relative 'octokit_client'
require_relative 'main_controller'
require_relative 'mailler'

class ConflictChecker

  def initialize

    @email = Email.new
    @repositories = Config_reader.new.get_repos
    @client = OctokitClient.new
    @controller = MainController.new

    start

  end

  def start
    @repositories.each do |repo|

      repository = repo.repository_name

      github_pull_requests = @client.get_all_github_pr repository
      db_pull_requests = @controller.get_pr_by_repo repository

      github_pr_numbers = [].to_set
      db_pr_numbers = [].to_set

      if github_pull_requests != nil
        github_pull_requests.each do |git_nub_pr|
          github_pr_numbers.add(git_nub_pr['number'])
        end
        db_pull_requests.each do |db_pr|
          db_pr_numbers.add(db_pr[:pr_id].to_i)
        end

        new_pull_requests = db_pr_numbers ^ github_pr_numbers

        check_pull_requests_state new_pull_requests, repository

        check_for_new_conflicts db_pull_requests, github_pull_requests, repository

      end
    end
  end

  def check_for_new_conflicts (db_pull_requests, github_pull_requests, repo)
    db_pull_requests.each do |db_pr|
      if db_pr.mergeable == 'true'
        puts "Checking stack"
        github_pull_requests.each do |gh_pr|
          if db_pr.pr_id.to_i == gh_pr.number.to_i
            this_pull = @client.get_github_pr_by_number repo, db_pr.pr_id

            #Console log
            puts '-----------'
            puts gh_pr.number
            puts "db -> #{db_pr.mergeable}"
            puts "gh -> #{this_pull.mergeable}"

          end
        end
      end
    end
  end

  def check_pull_requests_state (pull_requests, repository)

    pull_requests.each do |pr|

      db_request = @controller.get_pr_by_id pr

      db_request.each do |db_item|

        puts 'pr # ' + db_item.pr_id
        puts 'state in db ' + db_item.state

        github_request = @client.get_github_pr_by_number repository, pr

        if github_request.merged
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
