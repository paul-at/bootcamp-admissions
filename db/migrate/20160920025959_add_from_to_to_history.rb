class AddFromToToHistory < ActiveRecord::Migration[5.0]
  def change
    add_column :histories, :from, :string
    add_column :histories, :to, :string
  end
end
