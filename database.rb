require 'active_record'

def init_database

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

def create_pull_request_in_db pull_request_data
  PullRequest.create(
      :title => pull_request_data[:title],
      :pr_id => pull_request_data[:number],
      :author => pull_request_data[:user_login],
      :merged => pull_request_data[:merged],
      :mergeable => pull_request_data[:mergeable],
      :mergeable_state => pull_request_data[:mergeable_state],
      :state => pull_request_data[:state],
      :pr_commentors => pull_request_data[:commentors].to_a.join(", "),
      :committer => pull_request_data[:committer].to_a.join(", "),
      :labels => pull_request_data[:label].to_a.join(", "),
      :created_at => pull_request_data[:created_at],
      :updated_at => pull_request_data[:updated_at],
      :added_to_database => Time.new,
  )

  commentors = pull_request_data[:commentors].to_a
  build_list_of_commentors commentors
end

def create_new_user_in_db user
  User.create(
      :user_login => user.login,
      :user_email => user.email,
      :git_hub_id => user.id,
      :enable => false,
  )
end

def update_pull_request_state pull_request, state
  pull_request.update(state: state)
end

# Getters

def get_all_pull_requests_from_db
  PullRequest.all
end

def get_pull_requests_by_state state
  PullRequest.all.where(state: state)
end

def get_pull_request_by_id pull_request_id
  PullRequest.find_by(pr_id: pull_request_id)
end

def get_recipients
  User.all.where(enable: true)
end

def get_user_by_login login
  User.where(user_login: login).take
end
