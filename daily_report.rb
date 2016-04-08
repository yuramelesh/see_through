#!/usr/bin/env ruby
require 'rubygems'
require_relative 'daily_report_mail'
require_relative 'config/config_reader'
require_relative 'octokit_client'
require_relative 'main_controller'

config = Config_reader.new
repositories = config.get_repos
users_from_yml = config.get_users_from_config_yml
@controller = MainController.new
@octokit_client = OctokitClient.new

users_from_yml.each do |user|
  @controller.sync_user_with_config user
end

def mail_sending (repo)
  recipients = @controller.get_recipients_list
  recipients.each do |user|
    send_mail user, repo
  end
end

repositories.each do |repo|

  repo = repo.repository_name

  pr_data = @octokit_client.get_all_github_pr repo
  if pr_data != nil
    pr_data.each do |pr|
      @octokit_client.check_pr_for_existing pr, repo
      @octokit_client.check_pr_status repo
    end
    mail_sending repo
  end
end
