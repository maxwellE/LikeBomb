require "#{File.dirname(__FILE__)}/../lib/like_bomb/like_bomb.rb"
require 'test/unit'

class TestLikeBomb < Test::Unit::TestCase
  def setup
    #To run tests you will need to save your key in a key.txt file in the gem's root.  This is done
    #to prevent people from saving their key anywhere in the source.
    @lb = LikeBomb.new(IO.readlines("#{File.dirname(__FILE__)}/../key.txt").first)
  end
  def test_get_friends
    #Ids have a standard format
    assert_match(/\A\d{7,}\z/, @lb.get_friends.values.first)
  end
  def test_get_statuses
    #statuses are variable between each friend, therefore the only safe test is a kind test, same is true for get photos
    assert_kind_of(Hash, @lb.get_statuses(@lb.get_friends.values.last))
  end
  def test_get_photos
    assert_kind_of(Hash, @lb.get_photos(@lb.get_friends.values.first))
  end
end
