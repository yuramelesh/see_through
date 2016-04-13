#!/usr/bin/env ruby
require 'rubygems'
require 'time_difference'
require_relative 'daily_report_mail'
require_relative 'config/config_reader'
require_relative 'octokit_client'
require_relative 'main_controller'
require_relative 'time_class'

@time = TimeClass.new
config = Config_reader.new
repositories = config.get_repos
users_from_yml = config.get_users_from_config_yml
@controller = MainController.new
@octokit_client = OctokitClient.new
@db = Database.new

users_from_yml.each do |user|
  @controller.sync_user_with_config user
end

recipients = @controller.get_recipients_list

def mail_sending (repo, recipients)
  recipients.each do |user|
    daily_report = @db.get_daily_report_state(user.user_login)
    if daily_report != nil
      if @time.check_sent_at(daily_report.sent_at)
        send_mail user, repo
      end
      @db.update_daily_report_date(user.user_login, Time.new.utc)
    else
      send_mail user, repo
      @db.create_daily_report(user.user_login, Time.new.utc)
    end
  end
end

recipients.each do |user|
  if @time.check_time(user.notify_at.to_s)
    if @time.check_sent_at(@db.get_daily_report_state(user.user_login).sent_at)
      repositories.each do |repos|
        repo = repos.repository_name
        pr_data = @octokit_client.get_all_github_pr repo
        if pr_data != nil
          pr_data.each do |pr|
            @octokit_client.check_pr_for_existing pr, repo
            @octokit_client.check_pr_status repo
          end
          mail_sending repo, recipients
        end
      end
      break
    end
  end
end
