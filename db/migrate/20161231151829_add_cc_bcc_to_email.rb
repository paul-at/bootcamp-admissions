class AddCcBccToEmail < ActiveRecord::Migration[5.0]
  def change
    add_column :emails, :cc, :string
    add_column :emails, :bcc, :string
    remove_column :emails, :copy_team
  end
end
