require 'rubygems'
require 'octokit'
require 'curb'
require 'net/http'
require 'json'
require_relative 'Config'
require_relative 'Mailing'
require_relative 'DataBase'

db_init

client = Octokit::Client.new(:access_token => GITHUB_TOKEN)

pull_requests_list = client.pull_requests(REPO)

pull_requests_list.each do |pr|

  pr_data = {}
  comments = [].to_set
  pr_label = [].to_set

  request_status = client.pull_request(REPO, pr.number)

  iss_comments = client.issue_comments(REPO, pr.number)
  iss_comments.each do |ic|
    label = client.issue(REPO, pr.number)
    label.labels.each do |l|
      pr_label.add(l.name)
    end
    comments.add(ic.user.login)
  end

  pr_comments = client.pull_request_comments(REPO, pr.number)
  pr_comments.each do |k|
    comments.add(k.user.login)
  end

  url = `curl  https://#{GITHUB_TOKEN}:x-oauth-basic@api.github.com/repos/#{REPO}/pulls/#{pr.number}/commits`
  resp = JSON.parse(url)
  committers = [].to_set

  resp.each do |a_commit|

    if a_commit['author'] != nil
      committers.add(a_commit['author']['login'])
    else
      committers.add(a_commit['commit']['author']['name'])
    end
  end

  pr_data[:merged] = request_status.merged
  pr_data[:mergeable] = request_status.mergeable
  pr_data[:mergeable_state] = request_status.mergeable_state
  pr_data[:commentors] = comments
  pr_data[:committers] = committers
  pr_data[:label] = pr_label

  add_to_base pr, pr_data

end

#mail_send(send_list)