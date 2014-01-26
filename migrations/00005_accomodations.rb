Sequel.migration do
  up do
    create_table(:accomodations, :charset => 'utf8mb4', :engine => 'InnoDB' ) do
      primary_key :id
      foreign_key :city_id, :cities
      column :price, BigDecimal, :size => [19,4]
    end

    dallas = self[:cities].where( :name => 'Dallas').first
    self[:accomodations].insert( :city_id => dallas[:id], :price => 90 )
  end

  down do
    drop_table :accomodations
  end

end
