# frozen_string_literal: true

module Weather
  # Geolocation class uses geocoder to parse the address provided 
  # one of the main task of geolocator is to return longitude and latitude
  class Geolocation
    attr_accessor :address

    def initialize(address)
      @address = address.to_s.strip
      raise ArgumentError, 'Address cannot be blank' if @address.blank?
    end

    def coordinates
      Geocoder.search(@address).first.coordinates
    end
  end
end
