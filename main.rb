#!/usr/bin/env ruby
require 'rubygems'
require_relative 'mailing'
require_relative 'config_reader'
require_relative 'octokit_client'
require_relative 'database_controller'

repositories = Config_reader.new.get_repos
users_from_yml = Config_reader.new.get_users_from_config_yml

init_database

users_from_yml.each do |user|
  Database_controller.new.sync_user_with_config user
end

def mail_sending repo
  recipients = Database_controller.new.get_recipients_list
  recipients.each do |user|
    send_mail user, repo
  end
end

repositories.each do |repo|

  repo = repo.repository_name

  pr_data = get_github_pr repo

  if pr_data.length != 0

    check_pr_for_existing pr_data

    check_pr_status repo

    mail_sending repo
  end
end
