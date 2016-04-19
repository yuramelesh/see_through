class CreatDatabase < ActiveRecord::Migration
  def change
    ActiveRecord::Schema.define do

      create_table :pull_requests do |table|
        table.column :repo, :string, :null => true
        table.column :title, :string, :null => false
        table.column :pr_id, :string, :null => false
        table.column :author, :string, :null => false
        table.column :merged, :boolean, :null => false
        table.column :mergeable, :boolean, :null => true
        table.column :mergeable_state, :string, :null => true
        table.column :state, :string, :null => true
        table.column :pr_commentors, :string, :null => true
        table.column :committer, :string, :null => true
        table.column :labels, :string, :null => true
        table.column :pr_create_time, :string, :null => true
        table.column :pr_update_time, :string, :null => true
        table.column :added_to_database, :string #:null => true

        table.timestamps :null => false
      end

      create_table :users do |table|
        table.column :user_login, :string, unique: true
        table.column :user_email, :string
        table.column :git_email, :string, :null => true
        table.column :git_hub_id, :integer, :null => true
        table.column :notify_at, :string
        table.column :enable, :boolean

        table.timestamps :null => false
      end

      create_table :repositories do |table|
        table.column :repo, :string

        table.timestamps :null => false
      end

      create_table :commentors do |table|
        table.column :pull_request_id, :integer #foreign key
        table.column :user_id, :string

        table.timestamps :null => false
      end

      create_table :daily_reports do |table|
        table.column :user_name, :string
        table.column :sent_at, :string

        table.timestamps :null => false
      end
    end
  end
end