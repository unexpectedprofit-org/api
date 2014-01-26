require 'app/registry'
require 'sequel'
require 'model/city_airport'

module Model
  class Airport < Sequel::Model (App::Registry.db[:airports])
  end
end
