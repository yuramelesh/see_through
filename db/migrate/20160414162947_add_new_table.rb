class AddNewTable < ActiveRecord::Migration
  def change
    create_table :tabla do |table|
      table.column :name, :string, :null => true
      table.column :title, :string, :null => false
      table.column :iddd, :string, :null => false

      table.timestamps :null => false
    end
  end
end
