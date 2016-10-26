class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
      t.string :subject
      t.text :body
      t.references :app_form, foreign_key: true, null: false
      t.boolean :copy_team, null: false, default: false
      t.boolean :sent, null: false, default: false
      t.string :sent_to
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
