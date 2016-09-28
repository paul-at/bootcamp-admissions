class DashboardController < ApplicationController
  def index
    @klasses = Klass.active.select{ |klass| can? :read, klass }
  end
end