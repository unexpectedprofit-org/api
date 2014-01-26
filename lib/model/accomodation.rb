require 'app/registry'
require 'sequel'

module Model
  class Accomodation < Sequel::Model (App::Registry.db[:accomodations])
    one_to_one :city
  end
end
