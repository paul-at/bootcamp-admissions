class ApiController < ApplicationController
  # Do not redirect API users to log in page
  skip_before_action :authenticate_user!

  def user
    unless params['key'] == ENV['API_KEY']
      render body: nil, status: 401
      return
    end

    af = AppForm.where(email: params['email']).visible.
      includes(:klass, klass: [:subject])

    if af.count == 0
      render body: nil, status: 404
      return
    end

    bootcamps = af.map{|f| {
      bootcamp_id: f.klass.subject_id,
      bootcamp_title: f.klass.subject.title,
    } }.uniq
    bootcamps.each do |bootcamp|
      bootcamp[:klasses] = af.
        select{ |f| f.klass.subject_id == bootcamp[:bootcamp_id] }.
        map{ |f| {
          klasse_id: f.klass_id,
          klasse_name: f.klass.title,
          status: f.aasm_state,
          is_user_eligible_to_pay: f.may_payment?,
        } }
    end

    render json: {
      user: params['email'],
      bootcamps: bootcamps,
    }
  end
end