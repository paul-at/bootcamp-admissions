class AddPhoneToAppForm < ActiveRecord::Migration[5.0]
  def change
    add_column :app_forms, :phone, :string
  end
end
