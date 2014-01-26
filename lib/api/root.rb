require 'grape'
require 'api/destination'

module API
  class Root < Grape::API
    format :json

    mount API::Destination
  end
end
