class DashboardController < ApplicationController
  def index
    unless params[:archived]
      klasses = Klass.active
    else
      klasses = Klass.archived
    end

    @klasses = klasses.select{ |klass| can? :read, klass }
  end
end