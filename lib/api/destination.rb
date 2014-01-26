require 'grape'
require 'model/destination'
require 'service/trip_calculator'
require 'model/city'
require 'entity/trip'

module API
  class Destination < Grape::API

    resource :destination do
      get "/:id" do
        city = Model::City.find( :name => 'Buenos Aires')
        present Service::TripCalculator.new.find_trips( city ), with: Entity::Trip
        #{ :message => Model::Destination[params[:id]] }
      end
    end

  end
end
