class DashboardController < ApplicationController
  STATISTIC_GROUPS = {
      rejected_total: [:decided_to_reject_application, :application_reject_email_sent,:rejected_after_interview, :decision_reject_email_sent],

      coming: [:coming],
      not_coming: [:not_coming],


      interviews: [:decided_to_invite, :invite_email_sent, :interview_scheduled, :invite_no_response, :no_show, :interviewed, :waitlisted, :waitlist_email_sent, :admitted, :admit_email_sent, :attending, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :decision_reject_email_sent, :coming, :not_coming],
      _invite_emails_pending: [:decided_to_invite],

      interviews_rejected: [:decided_to_reject_application, :application_reject_email_sent],
      _interview_reject_emails_pending: [:decided_to_reject_application],
      not_reviewed: [:applied],

      interviewed: [:interviewed, :waitlisted, :waitlist_email_sent, :admitted, :admit_email_sent, :attending, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :decision_reject_email_sent, :coming, :not_coming],
      no_show: [:no_show],

      decided_to_invite: [:decided_to_invite],
      invite_emails_sent: [:invite_email_sent],
      interviews_scheduled: [:interview_scheduled],
      invite_no_response: [:invite_no_response],


      admitted: [:admitted, :admit_email_sent, :attending, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :coming, :not_coming],
      _admit_emails_pending: [:admitted],

      rejected: [:rejected_after_interview, :decision_reject_email_sent],
      _reject_emails_pending: [:rejected_after_interview],

      waitlisted: [:waitlisted, :waitlist_email_sent],
      _waitlist_emails_pending: [:waitlisted],

      interviewed_and_in_limbo: [:interviewed],
  }

  def index
    load_klasses

    # query aggregate stats from database
    statistic = AppForm.where(klass: @klasses, deleted: false).group(:klass_id, :aasm_state).count

    # initialise statistic groups
    @statistic_groups = Hash.new
    @klasses.each do |klass|
      @statistic_groups[klass.id] = Hash.new
    end

    # calculate statistic groups
    statistic.each do |k,count|
      klass_id = k[0]
      state = k[1].to_sym
      STATISTIC_GROUPS.each do |group,constituents|
        if constituents.include?(state)
          @statistic_groups[klass_id][group] = @statistic_groups[klass_id][group].to_i + count
        end
      end
    end
  end

  def user
    load_klasses

    @klass_stats = Hash.new
    @vote_stats = Hash.new
    @interviewer_actions = Hash.new

    @klasses.each do |klass|
      @klass_stats[klass.id] = klass.todo_statistics
      @vote_stats[klass.id] = Vote.casted_in(klass)
      @interviewer_actions[klass.id] = klass.app_forms.visible.where(
        interviewer: current_user,
        aasm_state: ['interview_scheduled', 'invite_email_sent', 'interviewed']).
        group(:aasm_state).count
      # initialise searches with current user id
      klass.app_forms_by_klass_conditions(current_user.id)
    end
  end

  private
  def load_klasses
    unless params[:archived]
      klasses = Klass.active
    else
      klasses = Klass.archived
    end

    @klasses = klasses.
      includes(:subject).
      order('subjects.title', 'klasses.title').
      select{ |klass| can? :read, klass }
  end
end