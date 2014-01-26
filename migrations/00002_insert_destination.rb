Sequel.migration do
  up do
    self[:destinations].insert( :name => 'New York' )
    self[:destinations].insert( :name => 'Las Vegas' )
  end

  down do
    self[:destinations].truncate
  end
end
