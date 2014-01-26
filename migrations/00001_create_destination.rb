Sequel.migration do
  up do
    create_table(:destinations, :charset => 'utf8mb4', :engine => 'InnoDB' ) do
      primary_key :id
      column :name, String, :null => false
    end
  end

  down do
    drop_table :destinations
  end

end
