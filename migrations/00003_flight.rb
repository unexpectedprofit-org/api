Sequel.migration do
  up do
    create_table(:airports, :charset => 'utf8mb4', :engine => 'InnoDB' ) do
      primary_key :id
      column :iata_code, String, :fixed => true, :size => 3, :unique => true, :null => false
    end

    create_table(:flights, :charset => 'utf8mb4', :engine => 'InnoDB' ) do
      primary_key :id
      foreign_key :origin_id, :airports
      foreign_key :destination_id, :airports
      column :price, BigDecimal, :size => [19,4]
    end

    self[:airports].insert( :iata_code => 'EZE' )
    self[:airports].insert( :iata_code => 'DFW' )
    self[:flights].insert( :origin_id => 1, :destination_id => 2, :price => 1000 )

  end

  down do
    drop_table :flights
    drop_table :airports
  end

end
