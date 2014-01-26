require 'sequel'
require 'app/registry'

Sequel::Model.plugin :json_serializer

module Model
  class Destination < Sequel::Model (App::Registry.db[:destinations])
    set_primary_key :id
  end
end
