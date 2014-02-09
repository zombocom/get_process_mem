require 'test_helper'

class GetProcessMemTest < Test::Unit::TestCase

  def setup
    @mem = GetProcessMem.new
  end

  def test_seems_to_work
    assert @mem.kb    > 0
    assert @mem.mb    > 0
    assert @mem.gb    > 0
    assert @mem.bytes > 0
  end

  def test_conversions
    bytes = 0
    assert_equal 0.0, @mem.kb(bytes)
    assert_equal 0.0, @mem.mb(bytes)
    assert_equal 0.0, @mem.gb(bytes)

    # kb
    bytes = 1024
    assert_equal 1.0,                 @mem.kb(bytes)
    assert_equal 0.0009765625,        @mem.mb(bytes)
    assert_equal 9.5367431640625e-07, @mem.gb(bytes)

    # mb
    bytes = 1_048_576
    assert_equal 1024.0,              @mem.kb(bytes)
    assert_equal 1.0,                 @mem.mb(bytes)
    assert_equal 0.0009765625,        @mem.gb(bytes)

    # gb
    bytes = 1_073_741_824
    assert_equal 1048576.0,           @mem.kb(bytes)
    assert_equal 1024.0,              @mem.mb(bytes)
    assert_equal 1.0,                 @mem.gb(bytes)
  end
end