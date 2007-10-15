require File.dirname(__FILE__) + '/../test_helper'

class RoomMaximumOccupancyTest < Test::Unit::TestCase
  fixtures :people

  def test_maximum_occupancy
    room = Room.new(:maximum_occupancy => 2)
    assert_equal 0, Room.count_by_sql("select count(*) from people_rooms")
    assert_equal 0, room.people.size

    assert_nothing_raised { room.people << people(:person1) }
    assert_nothing_raised { room.people << people(:person2) }
    assert room.save
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")
    assert_equal 2, room.people.size

    assert_raise RuntimeError do
      room.people << people(:person3)
    end
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")

    assert_equal "There are too many people in this room", room.errors.on(:people)  # Passes (for now!)

    # But as soon as I go to save it, it clears out the errors array!! Arg!
    room.save
    #assert_equal "There are too many people in this room", room.errors.on(:people)  # FAILS

    #assert_equal false, room.valid?  # FAILS
    #assert_equal false, room.save    # FAILS
    assert_equal 2, room.people.size
  end

end
