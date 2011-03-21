require 'spec_helper'

describe RoomsController do
  describe "without authorisation" do
    it "should not allow access to the index page" do
      get :index
      response.should redirect_to(:controller => 'admin', :action => 'login')
    end
  end

  describe "with authorisation" do
    before do
      u = User.new(:name => 'Bob Builder', :username => 'bb', :access_level => 5, :password => 'asdfghjkl', :password_confirmation => 'asdfghjkl')
      u.save!

      session[:user_id] = u.id

      @room = Room.new(:name => 'Room 3', :number_of_computers => 50)
      @room.save!
      Room.stub!(:all).and_return([@room])
    end

    it "should allow access to the index page" do
      get :index
      response.should be_success
      response.should render_template("layouts/application")
    end

    it "should assign @rooms to [@room]" do
      get :index
      assigns[:rooms].should include(@room)
    end

    describe "creating a room" do
      before do
        Room.destroy_all
        get :index
        response.should be_success
      end

      it "should accept the correct attributes in a form" do
        post :create, {:room => {:name => 'Room 3', :number_of_computers => 50}}
        response.should redirect_to(:action => :index)

        Room.count.should == 1
      end

      it "should return errors with invalid attributes" do
        post :create, {:room => {:name => '2', :number_of_computers => -2}}
        response.should redirect_to(:action => :index)

        Room.count.should == 0
        flash[:notice].starts_with?("NO TRANSLATE").should be_true
        flash[:notice].should =~ /Error/i
      end
    end

    describe "deleting a room" do
      it "should accept a delete request" do
        delete :destroy, {:id => @room.id}
        Room.count.should == 0
      end

      it "should not delete a non-existant room" do
        delete :destroy, {:id => @room.id - 1} rescue
        Room.count.should == 1
      end
    end

    describe "editing a room" do
      it "should allow for editing" do
        put :update, {:id => @room.id, :room => {:name => 'Room 323', :number_of_computers => 70}}
        response.should redirect_to(:action => :index)

        Room.find(@room.id).name.should == "Room 323"
        Room.find(@room.id).number_of_computers.should == 70
      end

      it "shouldn't allow editing with invalid parameters" do
        put :update, {:id => @room.id, :room => {:name => '3', :number_of_computers => -1}}
        response.should redirect_to(:action => :index)

        flash[:notice].start_with?('NO TRANSLATE').should be_true
        flash[:notice].should =~ /.*too short.*/i

        Room.find(@room.id).name.should == 'Room 3'
      end
    end
  end
end

