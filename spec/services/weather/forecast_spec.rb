# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Weather::Forecast, type: :service do
  let(:lat) { 38.8698201 }
  let(:lon) { -106.984043 }
  let(:coordinates) { [38.8698201, -106.984043] }
  let(:forecast) { described_class.new(coordinates) }
  let(:api_key) { ENV.fetch('OPENWEATHER_API_KEY') }

  let(:api_url) do
    "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&lat=#{lat}&lon=#{lon}&units=imperial"
  end

  let(:response_body) do
    { 'coord' => { 'lon' => -106.984, 'lat' => 38.8698 },
      'weather' => [{ 'id' => 800, 'main' => 'Clear', 'description' => 'clear sky', 'icon' => '01d' }],
      'base' => 'stations',
      'main' => { 'temp' => 76.3, 'feels_like' => 74.25, 'temp_min' => 76.3, 'temp_max' => 76.3, 'pressure' => 1014, 'humidity' => 13,
                  'sea_level' => 1014, 'grnd_level' => 696 },
      'visibility' => 10_000,
      'wind' => { 'speed' => 16.42, 'deg' => 259, 'gust' => 23.82 },
      'clouds' => { 'all' => 0 },
      'dt' => 1_750_099_108,
      'sys' => { 'country' => 'US', 'sunrise' => 1_750_074_136, 'sunset' => 1_750_127_714 },
      'timezone' => -21_600,
      'id' => 5_418_523,
      'name' => 'Crested Butte',
      'cod' => 200 }.to_json
  end

  describe '#fetch' do
    context 'when api request is successful' do
      before do
        stub_request(:get, api_url)
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v2.13.1'
            }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it 'returns parsed JSON data' do
        result = forecast.fetch
        expect(result['main']['temp']).to eq(76.3)
        expect(result['main']['temp_min']).to eq(76.3)
        expect(result['main']['temp_max']).to eq(76.3)
        expect(result['weather'].first['main']).to eq('Clear')
      end
    end

    context 'when api return an error' do
      before do
        stub_request(:get, api_url)
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v2.13.1'
            }
          ).to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises an API error' do
        expect { forecast.fetch }.to raise_error('Forecast error: API Error 500: Internal Server Error')
      end
    end
  end
end
