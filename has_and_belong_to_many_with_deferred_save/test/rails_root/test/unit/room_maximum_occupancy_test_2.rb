require File.dirname(__FILE__) + '/../test_helper'

class RoomMaximumOccupancyTest < Test::Unit::TestCase
  fixtures :people

  def test_maximum_occupancy_using_build
    room = Room.new(:maximum_occupancy => 2)
    assert_equal 0, Room.count_by_sql("select count(*) from people_rooms")
    assert_equal 0, room.people.size

    room.people.build(:name => 'person1')
    room.people.build(:name => 'person2')
    assert room.save
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")
    assert_equal 2, room.people.size

    room.people.build(:name => 'person3')
    # Good, it prevented it from being saved to the database ...
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")
    # ... but it still added it to the collection stored in memory!
    #assert_equal 2, room.people.size  # Still FAILs. It thinks it has 3, even though the 3rd one is invalid.

    assert_equal false, room.save
    assert_equal "There are too many people in this room", room.errors.on(:people)

    # If we reload from what is stored in memory, it will still just have the 2 valid people...
    room.reload
    assert_equal 2, room.people.size
  end

end
