require_relative 'like_bomb'
require 'test/unit'

class TestLikeBomb < Test::Unit::TestCase
  def setup
    @lb = LikeBomb.new(IO.readlines("key.txt").first)
  end
  def test_get_friends
    assert_equal("12402794", @lb.get_friends.first["id"])
  end
  def test_get_statuses
    assert_equal("10151092099716018", @lb.get_statuses("697626017").first)
    assert_equal("103286529734130", @lb.get_statuses("697626017").last)
  end
  def test_get_photos
    assert_equal("2986670868510", @lb.get_photos("697626017").first)
    assert_equal("5109831017", @lb.get_photos("697626017").last)
  end
end
