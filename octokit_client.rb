#!/usr/bin/env rsuby
require 'octokit'
require_relative 'main_controller'

CLIENT = Octokit::Client.new(:access_token => ENV['SEE_THROUGH_TOKEN'])

class OctokitClient

  def initialize
    @mainController = MainController.new
  end

  def get_github_pr repo
    pr_data = {}

    begin
      pull_requests = CLIENT.pull_requests(repo)
      pull_requests.each do |pr|
        comments = [].to_set
        pr_label = [].to_set

        pr_additional_data = CLIENT.pull_request(repo, pr.number)
        pr_data[:user_login] = pr.user.login
        pr_data[:title] = pr.title
        pr_data[:number] = pr.number
        pr_data[:merged] = pr_additional_data.merged
        pr_data[:mergeable] = pr_additional_data.mergeable
        pr_data[:mergeable_state] = pr_additional_data.mergeable_state
        pr_data[:created_at] = pr_additional_data.created_at
        pr_data[:updated_at] = pr_additional_data.updated_at
        pr_data[:state] = pr_additional_data.state

        iss_comments = CLIENT.issue_comments(repo, pr.number)
        iss_comments.each do |ic|
          label = CLIENT.issue(repo, pr.number)
          label.labels.each do |l|
            pr_label.add(l.name)
          end
          comments.add(ic.user.login)
        end

        pr_data[:pr_label] = pr_label

        pr_comments = CLIENT.pull_request_comments(repo, pr.number)
        pr_comments.each do |k|
          comments.add(k.user.login)
        end

        pr_data[:comments] = comments

        resp = CLIENT.pull_request_commits(repo, pr.number)
        committers = [].to_set
        resp.each do |item|
          if item.committer != nil
            committers.add(item.committer.login)
          else
            committers.add(item.commit.author.name)
          end
        end

        pr_data[:committers] = committers
        pr_data
      end
      pr_data
    rescue
      puts "No pull requests in #{repo}"
    end
    pr_data
  end

  def check_pr_status (repo)
    begin
      @mainController.get_pr_by_repo(repo).each do |pull_request|
        checking = CLIENT.pull_request(repo, pull_request.pr_id)
        if checking.merged.to_s == 'true'
          @mainController.update_pr_state pull_request, 'merged'
        else
          @mainController.update_pr_state pull_request, checking.state
        end

      end
    end
  end

  def get_all_github_pr (repo)
    begin
      pulls = CLIENT.pull_requests repo
      if pulls != nil
        return pulls
      end
    rescue
      puts "No pull requests in #{repo}"
    end
  end

  def get_github_user_by_login (login)
    CLIENT.user login
  end

  def get_github_pr_by_number (repo, number)
    CLIENT.pull_request repo, number
  end

  def check_pr_for_existing (pr_data, repo)
    @mainController.create_or_update_pr pr_data, repo
  end

end
