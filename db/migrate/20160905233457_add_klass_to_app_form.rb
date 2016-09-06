class AddKlassToAppForm < ActiveRecord::Migration[5.0]
  def change
    add_reference :app_forms, :klass, foreign_key: true
  end
end
