class CreateHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :histories do |t|
      t.references :app_form, foreign_key: true
      t.text :text
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
