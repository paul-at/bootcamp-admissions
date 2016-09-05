class CreateAppForms < ActiveRecord::Migration[5.0]
  def change
    create_table :app_forms do |t|
      t.string :aasm_state, index: true
      t.string :firstname, index: true
      t.string :lastname, index: true
      t.string :email, index: true
      t.string :country, limit: 2, index: true
      t.string :residence, index: true
      t.string :gender, limit: 1
      t.date :dob
      t.string :referral
      t.decimal :paid, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
      t.index :updated_at
    end
  end
end
