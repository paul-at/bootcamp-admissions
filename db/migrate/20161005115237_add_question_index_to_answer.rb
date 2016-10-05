class AddQuestionIndexToAnswer < ActiveRecord::Migration[5.0]
  def change
    add_index :answers, [:app_form_id, :question]
  end
end
