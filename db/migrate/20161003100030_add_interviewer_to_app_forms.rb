class AddInterviewerToAppForms < ActiveRecord::Migration[5.0]
  def change
    add_reference :app_forms, :interviewer
    add_foreign_key :app_forms, :users, column: :interviewer_id
  end
end
