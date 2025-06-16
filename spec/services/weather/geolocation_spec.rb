# frozen_string_literal: true

# spec/services/weather/geolocation_spec.rb
require 'rails_helper'

RSpec.describe Weather::Geolocation, type: :service do
  describe '#initialize' do
    it 'raises an error if address is blank' do
      expect { described_class.new('') }.to raise_error(ArgumentError, 'Address cannot be blank')
    end

    it 'strips whitespace from the address' do
      geo = described_class.new('  Denver, CO  ')
      expect(geo.address).to eq('Denver, CO')
    end
  end

  describe '#coordinates' do
    let(:address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
    let(:mock_result) { double('result', coordinates: [37.4221, -122.0841]) }

    before do
      allow(Geocoder).to receive(:search).with(address).and_return([mock_result])
    end

    it 'returns coordinates for a valid address' do
      geo = described_class.new(address)
      expect(geo.coordinates).to eq([37.4221, -122.0841])
    end
  end
end
