require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "empty attributes" do
    user = User.new
    assert !user.valid?

    # Password is valid because it is generated before creation
    assert_equal 3, user.errors.count, user.errors.full_messages.join('\n')
  end

  test "password confirmation" do
    assert users(:joe).update_attributes(:password => 'secret', :password_confirmation => 'secret')

    assert !users(:joe).update_attributes(:password => 'secret', :password_confirmation => 'Secret')
  end

  test "logging in" do
    assert !User.authenticate('jb', 'SECRET')
    assert User.authenticate('jb', 'secret')
  end

  test "unique user" do
    user = User.new :username => users(:joe).username, :name => 'yyy', :access_level => 1

    assert !user.valid?
  end

  test "access levels" do
    user = User.new :username => 'xxx', :name => 'yyyy', :access_level => 1
    assert user.valid?

    user.access_level = 2
    assert !user.valid?

    user.access_level = 4
    assert !user.valid?

    user.access_level = 5
    assert user.valid?
  end
end

