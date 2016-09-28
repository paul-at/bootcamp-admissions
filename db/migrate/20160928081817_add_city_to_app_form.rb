class AddCityToAppForm < ActiveRecord::Migration[5.0]
  def change
    add_column :app_forms, :city, :string
  end
end
