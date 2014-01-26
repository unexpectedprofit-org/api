require 'app/registry'
require 'sequel'
require 'model/airports'

module Model
  class Flight < Sequel::Model (App::Registry.db[:flights])
    many_to_one :origin, :class => Model::Airport
    many_to_one :destination, :class => Model::Airport
  end
end
