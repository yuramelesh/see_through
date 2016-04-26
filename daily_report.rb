#!/usr/bin/env ruby
require 'rubygems'
require 'time_difference'
require 'logger'
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
@db = Database.new
@logger = Logger.new('logfile.log')

@logger.info('daily_report start')

users_from_yml.each do |user|
  @controller.sync_user_with_config user
end

def mail_sending (repo, user)
  daily_report = @db.get_daily_report_state(user.user_login)
  if daily_report != nil
    if true#@time.check_time_pass(daily_report.sent_at, 24)
      send_mail user, repo
    end
    @db.update_daily_report_date(user.user_login, Time.new.utc)
  else
    send_mail user, repo
    @db.create_daily_report(user.user_login, Time.new.utc)
  end
end

repositories.each do |repos|

  if repos.recipients != nil
    data_existing = false

    repos.recipients.each do |repo_user|
      user = @controller.get_user_by_login(repo_user)

      if user.enable
        repo = repos.repository_name
        @controller.get_pr repo

        if true#@time.check_time(user.notify_at.to_s)
          repo = repos.repository_name

          unless data_existing
            @controller.get_pr repo
            data_existing = true
          end
          mail_sending repo, user
        end
      end
    end
  end
end

@logger.info('daily_report end')