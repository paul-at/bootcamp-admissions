class AttachmentsController < ApplicationController
  load_and_authorize_resource :app_form

  def create
    Attachment.create!({
      app_form: @app_form, 
      field: params[:attachment][:field], 
      upload: params[:attachment][:upload],
      user: current_user,
    })
    
    redirect_to @app_form, notice: 'File saved.'
  end
end