class SubscriptionsController < ApplicationController
  # GET /subscriptions
  def index
    load_subscriptions
  end

  # POST /subscriptions
  def create
    load_subscriptions

    requested_subscriptions = params[:klass_ids] ? params[:klass_ids].map(&:to_i) : []
    new_subscriptions = requested_subscriptions - @subscriptions
    remove_subscriptions = @subscriptions - requested_subscriptions

    unless can_subscribe?(new_subscriptions)
      redirect_to subscriptions_path, alert: 'Access forbidden.'
      return
    end

    new_subscriptions.each do |klass_id|
      Subscription.create!(klass_id: klass_id, user: current_user)
    end

    Subscription.where(klass_id: remove_subscriptions, user: current_user).delete_all

    redirect_to subscriptions_path, notice: 'Subscriptions updated.'
  end

  private
  def load_subscriptions
    @subscriptions = Subscription.where(user: current_user).map(&:klass_id)
  end

  def can_subscribe?(klass_ids)
    klass_ids.each do |klass_id|
      return false unless can? :read, Klass.find(klass_id)
    end
    return true
  end
end
