Sequel.migration do
  up do
    create_table(:city_airports, :charset => 'utf8mb4', :engine => 'InnoDB' ) do
      primary_key :id
      foreign_key :city_id, :cities
      foreign_key :airport_id, :airports
    end

    create_table(:cities, :charset => 'utf8mb4', :engine => 'InnoDB' ) do
      primary_key :id
      column :name, String, :null => false
      column :region, String, :null => false
      column :country, String, :null => false
      column :latitude, Float, :null => false
      column :longitude, Float, :null => false
    end


    bue = self[:cities].insert(
      :name => 'Buenos Aires',
      :region => 'Distrito Federal',
      :country => 'Argentina',
      :latitude => -34.59,
      :longitude => -58.67
    )

    dallas = self[:cities].insert(
      :name => 'Dallas',
      :region => 'Texas',
      :country => 'United States',
      :latitude => 32.78,
      :longitude => -96.81
    )

    self[:city_airports].insert( :city_id => bue, :airport_id => 1)
    self[:city_airports].insert( :city_id => dallas, :airport_id => 2)
  end

  down do
    drop_table :city_airports
    drop_table :cities
    self[:cities].where( :name => [ 'Buenos Aires', 'Dallas']).delete
  end

end
