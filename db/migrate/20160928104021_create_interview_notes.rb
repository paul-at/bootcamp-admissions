class CreateInterviewNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :interview_notes do |t|
      t.references :app_form, foreign_key: true
      t.references :user, foreign_key: true
      t.text :text

      t.timestamps
    end
  end
end
