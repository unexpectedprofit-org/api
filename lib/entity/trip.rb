require 'grape_entity'

module Entity
  class Trip < Grape::Entity
    expose :origin, :destination, :total
  end
end
