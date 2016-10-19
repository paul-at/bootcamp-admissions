class AddDeletedToAppForm < ActiveRecord::Migration[5.0]
  def change
    add_column :app_forms, :deleted, :boolean, null: false, default: false
  end
end
