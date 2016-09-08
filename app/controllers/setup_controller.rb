class SetupController < ApplicationController
  before_action :check_setup_enabled

  def index
  end

  def fake
    subject = Subject.create!(title: Faker::Educator.course)
    klass_id = Klass.create!(title: 'Class 1', subject: subject).id

    states = AppForm.aasm.states.map(&:name)

    for i in 1..params[:count].to_i
      appform = AppForm.create!({
        klass_id: klass_id,
        aasm_state: states.sample,
        firstname: Faker::Name.first_name,
        lastname: Faker::Name.last_name,
        email: Faker::Internet.email,
        country: Faker::Address.country_code,
        residence: Faker::Address.country_code,
        gender: ['M', 'F'].sample,
        dob: Faker::Date.between(50.years.ago, 18.years.ago),
      })
      Answer.create!(app_form: appform, question: 'what_do_you_value_most_in_life', answer: Faker::Company.catch_phrase)
      Answer.create!(app_form: appform, question: 'your_favourite_chuck_norris_fact', answer: Faker::ChuckNorris.fact)
    end

    redirect_to '/'
  end

  private

  def check_setup_enabled
    unless Rails.application.config.allow_faker
      render text: 'Disabled in server setup'
    end
  end
end