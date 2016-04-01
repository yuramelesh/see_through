#!/usr/bin/env ruby
require 'rubygems'
require 'active_record'
require 'octokit'
require 'curb'
require 'net/http'
require 'json'
require 'yaml'
require_relative 'Mailing'
require_relative 'DataBase'

@config = YAML.load_file('config.yml')
repo = @config['repositories'][0]['name']
organization = @config['repositories'][0]['organization']

db_init

@config['profiles'].each do |user|
  updating_user user
end

CLIENT = Octokit::Client.new(:access_token => ENV['SEE_THROUGH_TOKEN'])

repo_users_list = CLIENT.organization_members(organization)
user_list = [].to_set
repo_users_list.each do |user|
  user_list.add(user.login)
end

add_users_to_base user_list

# Getting pull requests information
pull_requests_list = CLIENT.pull_requests(repo)

pull_requests_list.each do |pr|
  pr_data = {}
  comments = [].to_set
  pr_label = [].to_set
  request_status = CLIENT.pull_request(repo, pr.number)

  iss_comments = CLIENT.issue_comments(repo, pr.number)
  iss_comments.each do |ic|
    label = CLIENT.issue(repo, pr.number)
    label.labels.each do |l|
      pr_label.add(l.name)
    end
    comments.add(ic.user.login)
  end

  pr_comments = CLIENT.pull_request_comments(repo, pr.number)
  pr_comments.each do |k|
    comments.add(k.user.login)
  end

  resp = CLIENT.pull_request_commits(repo, pr.number)
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
  pr_data[:state] = request_status.state

  check_pull_request pr, pr_data
end

def check_pull_status repo
  PullRequest.all.each do |pull_request|
    cheking = CLIENT.pull_request(repo, pull_request.pr_id)
    if cheking.merged.to_s == 'true'
      pull_request.update(state: 'merged')
    else
      pull_request.update(state: cheking.state)
    end
  end
end

check_pull_status repo

recipients = User.all.where(enable: true)
recipients.each do |user|
  mail_send user
end