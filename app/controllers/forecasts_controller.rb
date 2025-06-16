# frozen_string_literal: true

# controller to forecast the weather application.
class ForecastsController < ApplicationController
  def index; end
  def new; end

  def create
    @address = params[:address]
    geolocation = Weather::Geolocation.new(@address)
    @coordinates = geolocation.coordinates
    zip = geolocation.zipcode
    cache_key = "weather_#{zip}"
    @from_cache = Rails.cache.exist?(cache_key)

    @weather_data = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do 
      weather_forecast
    end

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

  def weather_forecast
    forecast = Weather::Forecast.new(@coordinates)
    forecast.fetch
  end
end
