#!/usr/bin/env ruby
require 'rubygems'
require_relative 'mailing'
require_relative 'config/config_reader'
require_relative 'octokit_client'
require_relative 'main_controller'

repositories = Config_reader.new.get_repos
users_from_yml = Config_reader.new.get_users_from_config_yml
@controller = MainController.new
@octokitClient = OctokitClient.new

users_from_yml.each do |user|
  @controller.sync_user_with_config user
end

def mail_sending repo
  recipients = @controller.get_recipients_list
  recipients.each do |user|
    send_mail user, repo
  end
end

repositories.each do |repo|

  repo = repo.repository_name

  pr_data = @octokitClient.get_github_pr repo

  if pr_data.length != 0

    @octokitClient.check_pr_for_existing pr_data

    @octokitClient.check_pr_status repo

    mail_sending repo
  end
end
