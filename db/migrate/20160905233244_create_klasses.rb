class CreateKlasses < ActiveRecord::Migration[5.0]
  def change
    create_table :klasses do |t|
      t.references :subject, foreign_key: true
      t.string :title
      t.boolean :archived, null: false, default: false
      t.decimal :deposit, precision: 10, scale: 2
      t.decimal :tuition, precision: 10, scale: 2

      t.timestamps
    end
  end
end
