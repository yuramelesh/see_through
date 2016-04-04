require 'active_record'
require 'json'

def db_init

  ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))

  ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => 'data.db'
  )

  def create_pull_request_table
    create_table :pull_requests do |t|
      t.column :title, :string, :null => false
      t.column :pr_id, :string, :null => false
      t.column :author, :string, :null => false
      t.column :merged, :boolean, :null => false
      t.column :mergeable, :boolean, :null => true
      t.column :mergeable_state, :string, :null => true
      t.column :state, :string, :null => true
      t.column :pr_commentors, :string, :null => true
      t.column :committer, :string, :null => true
      t.column :labels, :string, :null => true
      t.column :created_at, :string, :null => true
      t.column :updated_at, :string, :null => true
      t.column :added_to_database, :string #:null => true
    end
  end

  def create_users_table
    create_table :users do |table|
      table.column :user_login, :string, unique: true
      table.column :user_email, :string
      table.column :git_email, :string
      table.column :git_hub_id, :integer
      table.column :notify_at, :string
      table.column :enable, :boolean
    end
  end

  def build_list_of_commentors commentors_list
    commentors_list.each do |c|
      user = User.where(user_login: c)
      Commentor.create(
          :pull_request_id => pr.number,
          :user_id => user.first.id,
      )
    end
  end

  ActiveRecord::Schema.define do

    unless ActiveRecord::Base.connection.tables.include? 'pull_requests'
      create_pull_request_table
    end

    unless ActiveRecord::Base.connection.tables.include? 'users'
      create_users_table
    end

    unless ActiveRecord::Base.connection.tables.include? 'commentors'
      create_table :commentors do |table|
        table.column :pull_request_id, :integer #foreign key
        table.column :user_id, :string
      end
    end
  end
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

def add_new_pull_request pr, pr_additional_data
  PullRequest.create(
      :title => pr.title,
      :pr_id => pr.number,
      :author => pr.user.login,
      :merged => pr_additional_data[:merged],
      :mergeable => pr_additional_data[:mergeable],
      :mergeable_state => pr_additional_data[:mergeable_state],
      :state => pr_additional_data[:state],
      :pr_commentors => pr_additional_data[:commentors].to_a.join(", "),
      :committer => pr_additional_data[:committer].to_a.join(", "),
      :labels => pr_additional_data[:label].to_a.join(", "),
      :created_at => pr_additional_data[:created_at],
      :updated_at => pr_additional_data[:updated_at],
      :added_to_database => Time.new,
  )

  commentors_list = pr_additional_data[:commentors].to_a
  build_list_of_commentors commentors_list
end

def changes_check pr, pr_data
  existing_pull_requests = PullRequest.all
  existing_pull_requests.each do |pull_request|
    if pr.number == pull_request.pr_id
      if pull_request.merged != pr_data[:merged]
        pull_request.update(merged: pr_data[:merged])
      end
      if pull_request.state != pr_data[:state]
        pull_request.update(state: pr_data[:state])
      end
      if pull_request.mergeable != pr_data[:mergeable]
        pull_request.update(mergeable: pr_data[:mergeable])
      end
      if pull_request.mergeable_state != pr_data[:mergeable_state]
        pull_request.update(mergeable_state: pr_data[:mergeable_state])
      end
      if pull_request.committer != pr_data[:committer]
        pull_request.update(committer: pr_data[:committer])
      end
      if pull_request.labes != pr_data[:label]
        pull_request.update(labels: pr_data[:label])
      end
    end
  end
end

def check_pr_for_existing pr, pr_additional_data

  if PullRequest.find_by(pr_id: pr.number)
    changes_check pr, pr_additional_data
  else
    add_new_pull_request pr, pr_additional_data
  end
end

def add_new_user new_user
  user = CLIENT.user(new_user)
  User.create(
      :user_login => user.login,
      :user_email => user.email,
      :git_hub_id => user.id,
      :enable => true,

  )
end

def add_users_to_base user_list

  if User.all.length == 0
    user_list.each do |login|
      add_new_user login
    end
  else
    exist_user_list = JSON.parse(User.all.to_json)
    checking_users_list = [].to_set
    exist_user_list.each do |item|
      checking_users_list.add(item['user_login'])
    end
    user_list.each do |input_item|
      if checking_users_list.include? input_item
      else
        add_new_user input_item
      end
    end
  end
end

def sync_user_with_config user
  daily_report = user['enable'].to_s == 'true'
  user_to_update = User.where(user_login: user['login']).take
  user_to_update.update(enable: daily_report)
  user_to_update.update(notify_at: user['tz_shift'])
  user_to_update.update(user_email: user['email'])
end
