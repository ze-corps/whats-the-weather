# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  describe 'POST #create' do
    let(:address) { 'Crested Butte, Colorado' }
    let(:coordinates) { [38.8698201, -106.984043] }
    let(:postal_code) { 81_224 }
    let(:geolocation_double) { instance_double('Weather::Geolocation', coordinates: coordinates, zipcode: postal_code) }

    let(:weather_data) do
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
        'cod' => 200 }
    end

    before do
      allow(Weather::Geolocation).to receive(:new).with(address).and_return(geolocation_double)
      allow(Weather::Forecast).to receive(:new).with(coordinates).and_return(double(fetch: weather_data))
    end

    it 'assigns weather_data and renders index' do
      post :create, params: { address: address }

      expect(assigns(:weather_data)).to eq(weather_data)
      expect(response).to render_template(:index)
    end

    context 'when an error occurs' do
      let(:error_msg) { 'Connection Timeout' }

      before do
        allow(Weather::Geolocation).to receive(:new).with(address).and_return(geolocation_double)
        allow(Weather::Forecast).to receive(:new).and_raise(StandardError.new(error_msg))
      end

      it 'sets flash error and renders index' do
        post :create, params: { address: address }

        expect(flash.now[:error].message).to eq(error_msg)

        expect(response).to render_template(:index)
      end
    end
  end
end
