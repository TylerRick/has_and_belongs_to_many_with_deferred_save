require File.dirname(__FILE__) + '/../test_helper'

class RoomMaximumOccupancyTest < Test::Unit::TestCase
  fixtures :people

  def test_maximum_occupancy
    room = Room.new(:maximum_occupancy => 2)
    assert_equal 0, Room.count_by_sql("select count(*) from people_rooms")
    assert_equal 0, room.people.size

    room.people << people(:person1)
    room.people << people(:person2)
    assert room.save
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")
    assert_equal 2, room.people.size

    room.people << people(:person3)
    #assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")  # FAILS because it saves it in people_rooms before we even call room.save !

    assert_equal false, room.save
    # Good, it has the error ... 
    assert_equal "There are too many people in this room", room.errors.on(:people)
    # ... but it's too late. It didn't prevent the invalid data from getting in there!
    #assert_equal 2, room.people.size  # FAILS
  end
end
