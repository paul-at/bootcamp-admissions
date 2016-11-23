class AddAdmissionScholarshipTresholdsToKlass < ActiveRecord::Migration[5.0]
  def change
    add_column :klasses, :admission_threshold, :integer
    add_column :klasses, :scholarship_threshold, :integer
  end
end
