class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.references :app_form, foreign_key: true
      t.attachment :upload
      t.string :field
      t.string :original_file_name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
