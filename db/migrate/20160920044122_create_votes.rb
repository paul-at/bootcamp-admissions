class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :votes do |t|
      t.references :app_form, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :vote

      t.timestamps
    end
  end
end
