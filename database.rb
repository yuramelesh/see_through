require 'active_record'

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
