require 'app/registry'
require 'sequel'

module Model
  class CityAirport < Sequel::Model (App::Registry.db[:city_airports])
    many_to_one :city
    many_to_one :airport
  end
end
