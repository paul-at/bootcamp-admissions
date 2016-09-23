class UserScores
  extend ActiveModel::Naming

  attr_reader :scores

  def initialize(scores, user=nil)
    @scores = scores
    @user = user
  end

  def scores_attributes=(attributes)
  end

  def create_or_update!(attributes)
    attributes.values.each do |score_attributes|
      score = Score.find_or_create_by({
        app_form_id: score_attributes[:app_form_id],
        criterion: score_attributes[:criterion],
        user: @user,
      })
      score.score = score_attributes[:score]
      score.reason = score_attributes[:reason]
      score.save!
    end
  end

  def persisted?
    false
  end
end