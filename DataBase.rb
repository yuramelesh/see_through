require 'active_record'

def db_init

  ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))

  ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => 'data.db'
  )

  ActiveRecord::Schema.define do
    unless ActiveRecord::Base.connection.tables.include? 'pull_requests'
      create_table :pull_requests do |t|
        t.column :title, :string, :null => false
        t.column :pr_id, :string, :null => false
        t.column :author, :string, :null => false
        t.column :merged, :boolean, :null => false
        t.column :mergeable, :boolean, :null => true
        t.column :mergeable_state, :string, :null => true
        t.column :commentors, :string, :null => true
        t.column :committers, :string, :null => true
        t.column :labels, :string, :null => true
      end
    end
  end
end

class PullRequests < ActiveRecord::Base

end

def add_to_base i, pr_data

    PullRequests.create(
        :title => i.title,
        :pr_id => i.number,
        :author => i.user.login,
        :merged => pr_data[:merged],
        :mergeable => pr_data[:mergeable],
        :mergeable_state => pr_data[:mergeable_state],
        :commentors => pr_data[:commentors].to_a.join(", "),
        :committers => pr_data[:committers].to_a.join(", "),
        :labels => pr_data[:label].to_a.join(", "),
    )
end