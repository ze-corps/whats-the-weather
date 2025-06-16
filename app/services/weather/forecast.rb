# frozen_string_literal: true

require 'dotenv/load'

module Weather
  # Forecast class that connects to the open weather api to get data
  # returns JSON
  class Forecast
    BASE_URL = 'https://api.openweathermap.org'
    API_KEY  = ENV.fetch('OPENWEATHER_API_KEY')

    def initialize(coordinates)
      @lat, @lon = coordinates
    end

    def fetch
      response = connection.get('/data/2.5/weather', {
                                  lat: @lat,
                                  lon: @lon,
                                  appid: API_KEY,
                                  units: 'imperial'
                                })

      raise "API Error #{response.status}: #{response.body}" unless response.success?

      JSON.parse(response.body)
    rescue StandardError => e
      raise "Forecast error: #{e.message}"
    end

    private

    def connection
      Faraday.new(
        url: BASE_URL,
        request: {
          timeout: 5,
          open_timeout: 3
        }
      )
    end
  end
end
