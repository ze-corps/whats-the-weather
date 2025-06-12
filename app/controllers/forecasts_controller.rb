# frozen_string_literal: true

# controller to forecast the weather application.
class ForecastsController < ApplicationController
  def index; end
  def new; end
  def create
    byebug
    render :index
  end

  private
  
  def forecast_params
    params.permit(
      :address
    )
  end
end
