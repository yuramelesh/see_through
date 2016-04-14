require 'active_record'

class Database

  def initialize
    init_database
  end

  class User < ActiveRecord::Base
    belongs_to :commentors
  end

  class PullRequest < ActiveRecord::Base
    has_many :commentors
  end

  class Commentor < ActiveRecord::Base
    belongs_to :pull_request
    has_one :users
  end

  class Repository < ActiveRecord::Base
  end

  class DailyReport < ActiveRecord::Base
  end

  def create_pull_request (pull_request_data, repo, pr)
    PullRequest.create(
        :repo => repo,
        :title => pull_request_data[:title],
        :pr_id => pull_request_data[:number],
        :author => pull_request_data[:user][:login],
        :merged => pr.merged,
        :mergeable => pr.mergeable,
        :mergeable_state => pr.mergeable_state,
        :state => pull_request_data[:state],
        # :pr_commentors => pull_request_data[:commentors].to_a.join(', '),
        :committer => pull_request_data[:committer].to_a.join(', '),
        :labels => pr.head.label,
        :pr_create_time => pull_request_data[:created_at],
        :pr_update_time => pull_request_data[:updated_at],
        :added_to_database => Time.new,
    )
    # commentors = pull_request_data[:commentors].to_a
    # build_list_of_commentors commentors
  end

  def create_new_user (user)
    User.create(
        :user_login => user.login,
        :user_email => user.email,
        :notify_at => user.tz_shift,
        :git_hub_id => user.id,
        :enable => false,
    )
  end

  def create_daily_report (user_login, sent_time)
    DailyReport.create(
        :user_name => user_login,
        :sent_at => sent_time,
    )
  end

  def create_repository (repository)
    Repository.create(
        :repo => repository
    )
  end

  def update_daily_report_date (user_login, sent_time)
    dr = DailyReport.where(user_name: user_login).first
    dr.update(:sent_at => sent_time)
  end

  def update_pull_request_state (pull_request, state)
    pull_request.update(state: state)
  end

# Getters
  def get_daily_report_state (user_login)
    DailyReport.where(user_name: user_login).first
  end

  def get_daily_reports_state
    DailyReport.all
  end

  def get_repo_pr_by_state (repo, state)
    PullRequest.where(repo: repo, state: state)
  end

  def get_pull_requests_by_repo (repo)
    PullRequest.where(repo: repo)
  end

  def get_all_repositories
    Repository.all
  end

  def get_repo_pr_by_mergeable (repo, state)
    PullRequest.where(repo: repo, mergeable: state)
  end

  def get_pull_requests_by_mergeable (state)
    PullRequest.where(mergeable: state)
  end

  def get_pull_requests_by_id (id)
    PullRequest.where(pr_id: id)
  end

  def get_all_pull_requests
    PullRequest.all
  end

  def get_pull_requests_by_state (state)
    PullRequest.all.where(state: state)
  end

  def get_pull_request_by_id (pull_request_id)
    PullRequest.find_by(pr_id: pull_request_id)
  end

  def get_recipients
    User.all.where(enable: true)
  end

  def get_user_by_login (login)
    User.where(user_login: login).take
  end

  def init_database

    ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))

    ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3',
        :database => 'data.db'
    )

    ActiveRecord::Schema.new.migrations_paths

      # ActiveRecord::Schema.define do
    #
    #   def create_pull_request_table
    #     create_table :pull_requests do |table|
    #       table.column :repo, :string, :null => true
    #       table.column :title, :string, :null => false
    #       table.column :pr_id, :string, :null => false
    #       table.column :author, :string, :null => false
    #       table.column :merged, :boolean, :null => false
    #       table.column :mergeable, :boolean, :null => true
    #       table.column :mergeable_state, :string, :null => true
    #       table.column :state, :string, :null => true
    #       table.column :pr_commentors, :string, :null => true
    #       table.column :committer, :string, :null => true
    #       table.column :labels, :string, :null => true
    #       table.column :pr_create_time, :string, :null => true
    #       table.column :pr_updated_time, :string, :null => true
    #       table.column :added_to_database, :string #:null => true
    #
    #       table.timestamps :null => false
    #     end
    #   end
    #
    #   def create_users_table
    #     create_table :users do |table|
    #       table.column :user_login, :string, unique: true
    #       table.column :user_email, :string
    #       table.column :git_email, :string, :null => true
    #       table.column :git_hub_id, :integer, :null => true
    #       table.column :notify_at, :string
    #       table.column :enable, :boolean
    #
    #       table.timestamps :null => false
    #     end
    #   end
    #
    #   def create_repositories_table
    #     create_table :repositories do |table|
    #       table.column :repo, :string
    #
    #       table.timestamps :null => false
    #     end
    #   end
    #
    #   def create_commenters_table
    #     create_table :commentors do |table|
    #       table.column :pull_request_id, :integer #foreign key
    #       table.column :user_id, :string
    #
    #       table.timestamps :null => false
    #     end
    #   end
    #
    #   def create_daily_reports_table
    #     create_table :daily_reports do |table|
    #       table.column :user_name, :string
    #       table.column :sent_at, :string
    #
    #       table.timestamps :null => false
    #     end
    #   end
    #
    #   unless ActiveRecord::Base.connection.tables.include? 'daily_reports'
    #     create_daily_reports_table
    #   end
    #
    #   unless ActiveRecord::Base.connection.tables.include? 'pull_requests'
    #     create_pull_request_table
    #   end
    #
    #   unless ActiveRecord::Base.connection.tables.include? 'users'
    #     create_users_table
    #   end
    #
    #   unless ActiveRecord::Base.connection.tables.include? 'commentors'
    #     create_commenters_table
    #   end
    #
    #   unless ActiveRecord::Base.connection.tables.include? 'repositories'
    #     create_repositories_table
    #   end
    # end
  end
end
