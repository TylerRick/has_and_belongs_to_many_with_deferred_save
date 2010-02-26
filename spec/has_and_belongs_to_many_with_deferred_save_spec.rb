require "spec_helper"
require 'has_and_belongs_to_many_with_deferred_save'

describe "has_and_belongs_to_many_with_deferred_save" do
  describe "room maximum_occupancy" do
    before :all do
      @people = []
      @people << Person.create
      @people << Person.create
      @people << Person.create
      @room = Room.new(:maximum_occupancy => 2)
    end

    it "initial checks" do
      Room  .count.should == 0
      Person.count.should == 3

      @room.people.should == []
      @room.people_without_deferred_save.should == []
      @room.people_without_deferred_save.object_id.should_not ==
        @room.unsaved_people.object_id
    end

    it "after adding people to room, it should not have saved anything to the database" do
      @room.people << @people[0]
      @room.people << @people[1]

      # Still not saved to the association table!
      Room.count_by_sql("select count(*) from people_rooms").should == 0
      @room.people_without_deferred_save.size.               should == 0
    end

    it "but room.people.size should still report the current size of 2" do
      @room.people.size.should == 2        # 2 because this looks at unsaved_people and not at the database
    end

    it "after saving the model, the association should be saved in the join table" do
      @room.save    # Only here is it actually saved to the association table!
      @room.errors.full_messages.should == []
      Room.count_by_sql("select count(*) from people_rooms").should == 2
      @room.people.size.                                     should == 2
      @room.people_without_deferred_save.size.               should == 2
    end

    it "when we try to add a 3rd person, it should add a validation error to the errors object like any other validation error" do
      lambda { @room.people << @people[2] }.should_not raise_error
      @room.people.size.       should == 3

      Room.count_by_sql("select count(*) from people_rooms").should == 2
      @room.valid?
      @room.errors.on(:people).should == "There are too many people in this room"
      @room.people.size.       should == 3 # Just like with normal attributes that fail validation... the attribute still contains the invalid data but we refuse to save until it is changed to something that is *valid*.
    end

    it "when we try to save, it should fail, because room.people is still invaild" do
      @room.save.should == false
      Room.count_by_sql("select count(*) from people_rooms").should == 2 # It's still not there, because it didn't pass the validation.
      @room.errors.on(:people).should == "There are too many people in this room"
      @room.people.size.       should == 3
    end

    it "when we reload, it should go back to only having 2 people in the room" do
      @room.reload
      @room.people.size.                                     should == 2
      @room.people_without_deferred_save.size.               should == 2
    end

    it "if they try to go around our accessors and use the original accessors, then (and only then) will the exception be raised in before_adding_person..." do
      lambda do
        @room.people_without_deferred_save << @people[2]
      end.should raise_error(RuntimeError)
    end
  end
end
