require 'spec_helper'

describe User do
  let(:bob) { User.new(:username => 'bb', :name => 'Bob Builder', :password => 'secret', :password_confirmation => 'secret', :access_level => 1) }
  let(:phil) { User.new(:username => 'pb', :name => 'Phil Bloggs', :password => 'secret', :password_confirmation => 'secret', :access_level => 1) }

  subject { bob }

  it { should be_valid }
  its(:username) { should == 'bb' }
  its(:name) { should == 'Bob Builder' }
  its(:access_level) { should == 1 }

  it "should force password confirmation" do
    bob.password = 'bowkejwe'
    bob.password_confirmation = 'different bowkejwe2'

    bob.save.should_not be_true

    bob.password = 'asdfghjkl'
    bob.password_confirmation = 'asdfghjkl'

    bob.save.should be_true
  end

  it "should log in" do
    bob.save.should be_true

    User.authenticate('bb', 'SECRET').should be_nil
    User.authenticate('bb', 'secret').should == bob
  end

  it "should have a unique username" do
    new_user = User.new(:username => bob.username, :name => 'Bob Brydon', :password => 'dfdsfsdfsdf', :password_confirmation => 'dfdsfsdfsdf', :access_level => 3)

    bob.save.should be_true
    new_user.save.should_not be_true
  end

  it "should validate access levels" do
    bob.should be_valid

    bob.access_level = 2
    bob.should_not be_valid

    bob.access_level = 4
    bob.should_not be_valid
  end
end

