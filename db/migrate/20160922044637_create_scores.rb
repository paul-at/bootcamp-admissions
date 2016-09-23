class CreateScores < ActiveRecord::Migration[5.0]
  def change
    create_table :scores do |t|
      t.references :app_form, foreign_key: true
      t.references :user, foreign_key: true
      t.string :criterion
      t.integer :score
      t.string :reason

      t.timestamps
    end
    add_index :scores, :criterion

    add_column :klasses, :scoring_criteria, :text
  end
end
