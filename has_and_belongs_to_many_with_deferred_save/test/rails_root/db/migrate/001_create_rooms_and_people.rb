class CreateRoomsAndPeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :name, :string
    end
    create_table :rooms do |t|
      t.column :name, :string
      t.column :maximum_occupancy, :integer
    end
    create_table :people_rooms do |t|
      t.column :person_id, :integer
      t.column :room_id, :integer
    end
  end

  def self.down
    drop_table :people
    drop_table :rooms
    drop_table :people_rooms
  end
end
