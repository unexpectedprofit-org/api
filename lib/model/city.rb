require 'app/registry'
require 'sequel'

module Model
  class City < Sequel::Model (App::Registry.db[:cities])
  end
end
