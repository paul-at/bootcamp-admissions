class Attachment < ApplicationRecord
  belongs_to :app_form
  has_attached_file :upload
  belongs_to :user, optional: true

  validates :upload, attachment_presence: true
  validates_with AttachmentSizeValidator, attributes: :upload, less_than: Rails.application.config.uploads_max_size
  do_not_validate_attachment_file_type :upload

  before_create :randomize_file_name

  private

  def randomize_file_name
    self.original_file_name = upload_file_name
    extension = File.extname(upload_file_name).downcase
    self.upload.instance_write(:file_name, "#{app_form.firstname.parameterize}_#{app_form.lastname.parameterize}_#{SecureRandom.hex(8)}#{extension}")
  end
end
