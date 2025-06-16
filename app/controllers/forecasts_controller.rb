# frozen_string_literal: true

# controller to forecast the weather application.
class ForecastsController < ApplicationController
  def index; end
  def new; end

  def create
    @address = params[:address]
    geolocation = Weather::Geolocation.new(@address)
    coordinates = geolocation.coordinates

    forecast = Weather::Forecast.new(coordinates[0], coordinates[1])
    @weather_data = forecast.fetch
    render :index
  rescue StandardError => e
    flash.now[:error] = e
    render :index
  end

  private

  def forecast_params
    params.permit(
      :address
    )
  end
end
