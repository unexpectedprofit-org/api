require 'model/city'
require 'model/city_airport'
require 'model/flight'
require 'model/airports'
require 'model/accomodation'
require 'model/trip'

module Service
  class TripCalculator
    def find_trips( origin )
      airport = Model::CityAirport[origin.id].airport

      flights = Model::Flight.filter( :origin_id => airport.id )

      trips = Array.new

      flights.each do |f|
        Model::CityAirport.filter( :airport => f.destination  ).each do |c|
          Model::Accomodation.filter( :city_id => c.city_id ).each do |a|
            trip = Model::Trip.new
            trip.origin = origin
            trip.destination = c.city
            trip.total = (a.price + f.price).round
            trips.push(trip)
          end
        end
      end

      return trips
      
    end
  end
end
