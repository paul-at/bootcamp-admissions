class AddResidenceCityToAppForm < ActiveRecord::Migration[5.0]
  def change
    add_column :app_forms, :residence_city, :string
  end
end
