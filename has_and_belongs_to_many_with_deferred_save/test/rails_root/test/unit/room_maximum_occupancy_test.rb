require File.dirname(__FILE__) + '/../test_helper'

class RoomMaximumOccupancyTest < Test::Unit::TestCase
  fixtures :people

#  def test_1
#    room = Room.new(:maximum_occupancy => 4)
#    room.maximum_occupancy = 10
#
#    assert_equal 10, room.maximum_occupancy   # Still invalid
#    assert_equal false, room.save
#    assert_equal "You can't have the maximum set so high", room.errors.on(:maximum_occupancy)
#    assert_equal 10, room.maximum_occupancy   # Still invalid
#  end

  def test_maximum_occupancy
    room = Room.new(:maximum_occupancy => 2)
    assert_equal [], room.people
    assert_equal [], room.people_without_deferred_save
    assert_not_equal room.unsaved_people.object_id, 
                     room.people_without_deferred_save.object_id

    assert_nothing_raised { room.people << people(:person1) }
    assert_nothing_raised { room.people << people(:person2) }
    assert_equal 0, Room.count_by_sql("select count(*) from people_rooms")  # Still not saved to the association table!
    assert_equal 0, room.people_without_deferred_save.size
    assert_equal 2, room.people.size        # 2 because this looks at unsaved_people

    assert room.save    # Only here is it actually saved to the association table!
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")
    assert_equal 2, room.people.size
    assert_equal 2, room.people_without_deferred_save.size

    assert_nothing_raised { room.people << people(:person3) }
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")  # person3 is not yet saved to the association table
    assert_equal false, room.valid?
    assert_equal "There are too many people in this room", room.errors.on(:people)

    assert_equal false, room.save
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")  # It's still not there, because it didn't pass the validation.
    assert_equal "There are too many people in this room", room.errors.on(:people)
    assert_equal 3, room.people.size    # Just like with normal attributes that fail validation... the attribute still contains the invalid data but we refuse to save until it is changed to something that is *valid*.

    room.reload
    assert_equal 2, room.people.size
    assert_equal 2, room.people_without_deferred_save.size

    assert_nothing_raised { room.people << people(:person3) }
    assert_equal 2, Room.count_by_sql("select count(*) from people_rooms")  # person3 is not yet saved to the association table

    # If they try to go around our accessors and use the original accessors, then (and only then) will the exception be raised in before_adding_person...
    assert_raise RuntimeError do
      room.people_without_deferred_save << people(:person3)
    end
  end
end
