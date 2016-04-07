#!/usr/bin/env ruby
require 'net/smtp'
require_relative 'config/config_reader'
require_relative 'octokit_client'
require_relative 'main_controller'
require_relative 'mailler'

class ConflictChecker

  def initialize

    @db = Database.new
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

        merged = []
        conflict = []

        new_pull_requests = db_pr_numbers ^ github_pr_numbers
        merged.push(check_pull_requests_state(new_pull_requests, repository).to_s)
        conflict.push(check_for_new_conflicts(db_pull_requests, github_pull_requests, repository).to_s)

        merg = ''
        merged.each do |m|
          merg << m
        end

        conf = ''
        conflict.each do |c|
          conf << c
        end

        create_mail repo, merg, conf

      end
    end
  end

  def check_pull_requests_state (pull_requests, repository)
    message =[]
    pull_requests.each do |pr|
      github_request = @client.get_github_pr_by_number repository, pr
      if github_request.merged
        message.push(github_request.number)
        message.push(github_request.title)
      end
    end
    return message
  end

  def check_for_new_conflicts (db_pull_requests, github_pull_requests, repo)
    message = []
    db_pull_requests.each do |db_pr|
      if db_pr.mergeable
        github_pull_requests.each do |gh_pr|
          if db_pr.pr_id.to_i == gh_pr.number.to_i
            this_pull = @client.get_github_pr_by_number repo, db_pr.pr_id
            if !this_pull.mergeable
              message.push(this_pull.number)
              message.push(this_pull.title)
            end
          end
        end
      end
    end
    return message
  end

  def create_mail (repo, merged, conflict)
    if merged.length > 2
      message = <<EOF
From: #{repo.repository_name} <FROM@vgs.io>
To: WorkGroup
Subject: Status Report - #{repo.repository_name}
Mime-Version: 1.0
Content-Type: text/html

<h4>Merged pull request:</h4>
 <p>#{merged.to_s}</p>

<h4>Become in conflict:</h4>
 <p>#{conflict.to_s}</p>

EOF
      recipients = @controller.get_recipients_list
      recipients.each do |user|
        send_mail message, user
      end
    end
  end
end

def send_mail (message, user_to)
  @email.send_mail(message, user_to.user_email)
end

ConflictChecker.new
