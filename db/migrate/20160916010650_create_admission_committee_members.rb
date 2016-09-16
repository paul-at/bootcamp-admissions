class CreateAdmissionCommitteeMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :admission_committee_members do |t|
      t.references :user, foreign_key: true
      t.references :klass, foreign_key: true

      t.timestamps
    end
  end
end
