class CreatePaymentTiers < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_tiers do |t|
      t.string :title
      t.decimal :deposit, precision: 10, scale: 2
      t.decimal :tuition, precision: 10, scale: 2

      t.timestamps
    end

    remove_column :klasses, :deposit
    remove_column :klasses, :tuition
    add_reference :klasses, :payment_tier, foreign_key: true
    add_reference :app_forms, :payment_tier, foreign_key: true
  end
end
