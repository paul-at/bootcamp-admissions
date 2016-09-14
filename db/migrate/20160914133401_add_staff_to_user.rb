class AddStaffToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :staff, :boolean, default: false, null: false
  end
end
