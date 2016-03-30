require 'rubygems'
require 'octokit'
require 'curb'
require 'net/http'
require 'json'
require_relative 'Config'
require_relative 'Mailing'
require_relative 'DataBase'

db_init

CLIENT = Octokit::Client.new(:access_token => GIT_HUB_TOKEN)



# Getting users from database
repo_users_list = CLIENT.organization_members(ORGANIZATION)

user_list = [].to_set

repo_users_list.each do |user|
  user_list.add(user.login)
end

mail_send

add_users_to_base user_list

# Getting pull requests information
pull_requests_list = CLIENT.pull_requests(REPO)

pull_requests_list.each do |pr|

  pr_data = {}
  comments = [].to_set
  pr_label = [].to_set

  request_status = CLIENT.pull_request(REPO, pr.number)

  iss_comments = CLIENT.issue_comments(REPO, pr.number)
  iss_comments.each do |ic|
    label = CLIENT.issue(REPO, pr.number)
    label.labels.each do |l|
      pr_label.add(l.name)
    end
    comments.add(ic.user.login)
  end

  pr_comments = CLIENT.pull_request_comments(REPO, pr.number)
  pr_comments.each do |k|
    comments.add(k.user.login)
  end

  resp = CLIENT.pull_request_commits(REPO, pr.number)
  committers = [].to_set
  resp.each do |item|

    if item.committer != nil
      committers.add(item.committer.login)
    else
      committers.add(item.commit.author.name)
    end
  end

  pr_data[:merged] = request_status.merged
  pr_data[:mergeable] = request_status.mergeable
  pr_data[:mergeable_state] = request_status.mergeable_state
  pr_data[:commentors] = comments
  pr_data[:committer] = committers
  pr_data[:label] = pr_label
  pr_data[:created_at] = request_status.created_at
  pr_data[:updated_at] = request_status.updated_at

  check_pull_request pr, pr_data

end