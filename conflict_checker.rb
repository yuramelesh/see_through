#!/usr/bin/env ruby
require 'net/smtp'
require_relative 'config/config_reader'
require_relative 'octokit_client'
require_relative 'main_controller'
require_relative 'mailler'
require_relative 'time_class'

class ConflictChecker

  def initialize
    @email = Email.new
    @repositories = Config_reader.new.get_repos
    @client = OctokitClient.new
    @controller = MainController.new
    @time = TimeClass.new

    start

  end

  def start

    @repositories.each do |repo|

      repository = repo.repository_name
      old_pr = @controller.get_repo_pr_by_mergeable repository, false
      old_pr_block = ''
      old_pr_block << "<h2>Pull requests with issues</h2><hr>"
      old_pr.each do |pr|
        old_pr_block << "<h3>Pull Request -  #{pr.title} <a href='https://github.com/#{repository}/pull/#{pr.pr_id}/'>##{pr.pr_id}</a></h3>
        <p>Author: #{pr.author}</p>
        <p>Time in conflict: <b><span style='color: red;'> #{@time.get_conflict_time pr}</span></b></p><br>"
      end

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

        merged = '<h2>Recently merged</h2><hr>'
        conflict = '<h2>Now in conflict</h2><hr>'

        new_pull_requests = db_pr_numbers ^ github_pr_numbers

        check_pull_requests_state(new_pull_requests, repository).each do |pr|
          merged << "<h3>Pull Request -  #{pr.title} <a href='https://github.com/#{repository}/pull/#{pr.number}/'>##{pr.number}</a></h3>
        <p>Author: #{pr.user.login}</p><br>"
        end

        recipients = [].to_set

        check_for_new_conflicts(db_pull_requests, github_pull_requests, repository).each do |pr|
          pull = @controller.get_pr_by_id pr.number
          recipients.add(@controller.get_user_by_login(pull[0].author)[:user_email])
          conflict << "<h3>Pull Request -  #{pull[0][:title]} <a href='https://github.com/#{repository}/pull/#{pull[0].pr_id}/'>##{pull[0].pr_id}</a></h3>
        <p>Author: #{pull[0].author}</p>
        <p>Time in conflict: <b><span style='color: red;'> #{@time.get_conflict_time(pull[0])}</span></b></p><br>"
        end

        create_mail repo, merged, conflict, old_pr_block, recipients

      end
    end
  end

  def check_pull_requests_state (pull_requests, repository)
    pull = []
    pull_requests.each do |pr|
      github_request = @client.get_github_pr_by_number repository, pr
      if github_request.merged
        pull.push(github_request)
      end
    end
    return pull
  end

  def check_for_new_conflicts (db_pull_requests, github_pull_requests, repo)
    pull = []
    db_pull_requests.each do |db_pr|
      if db_pr.mergeable
        github_pull_requests.each do |gh_pr|
          if db_pr.pr_id.to_i == gh_pr.number.to_i
            this_pull = @client.get_github_pr_by_number repo, db_pr.pr_id
            if this_pull.mergeable == false
              pull.push(this_pull)
            end
          end
        end
      end
    end
    return pull
  end

  def create_mail (repo, merged, conflict, old_pr_block, recipients)

    if merged.length > 2
      message = <<EOF
From: #{repo.repository_name} <FROM@vgs.io>
To: WorkGroup
Subject: Merge Conflicts - #{repo.repository_name}
Mime-Version: 1.0
Content-Type: text/html

 #{merged}

      #{
      if conflict.length > 28
        conflict
      end
      }

      #{old_pr_block}

EOF

      Config_reader.new.get_users_from_config_yml.each do |user|
        @controller.sync_user_with_config user
      end

      recipients.each do |user|
        @email.send_mail(message, user)
      end
    end
  end
end

ConflictChecker.new
