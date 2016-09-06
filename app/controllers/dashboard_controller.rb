class DashboardController < ApplicationController
  def index
    @klasses = Klass.active
  end
end