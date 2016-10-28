class CreateEmailRules < ActiveRecord::Migration[5.0]
  def change
    create_table :email_rules do |t|
      t.references :klass, foreign_key: true, null: false
      t.string :state, null: false
      t.references :email_template, foreign_key: true, null: false
      t.boolean :copy_team, null: false, default: false

      t.timestamps

      t.index [:klass_id, :state]
    end
  end
end
