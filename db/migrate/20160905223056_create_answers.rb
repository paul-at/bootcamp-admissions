class CreateAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :answers do |t|
      t.references :app_form, foreign_key: true
      t.string :question
      t.text :answer

      t.timestamps
    end
  end
end
