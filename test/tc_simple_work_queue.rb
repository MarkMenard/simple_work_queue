##
# = Name
# TC_SimpleWorkQueue
#
# == Description
# This file contains unit tests for the SimpleWorkQueue class.
#
# == Author
# Miguel Fonseca <fmmfonseca@gmail.com>
#
# == Copyright
# Copyright 2009-2010 Miguel Fonseca
#
# == License
# MIT (see LICENSE file)

require 'test/unit'
require 'lib/simple_work_queue'

class TC_SimpleWorkQueue < Test::Unit::TestCase

  # def setup
  # end

  # def teardown
  # end

  def test_enqueue
    s = String.new
    wq = SimpleWorkQueue.new
    # using proc
    wq.enqueue_p(Proc.new { |str| str.replace("Hello #1") }, s)
    wq.join
    assert_equal("Hello #1", s)
    # using block
    wq.enqueue_b(s) { |str| str.replace("Hello #2") }
    wq.join
    assert_equal("Hello #2", s)
  end

  def test_max_threads
    assert_raise(ArgumentError) { SimpleWorkQueue.new(0) }
    assert_raise(ArgumentError) { SimpleWorkQueue.new(-1) }
    wq = SimpleWorkQueue.new(1)
    assert_equal(0, wq.cur_threads)
    wq.enqueue_b { sleep(0.01) }
    assert_equal(1, wq.cur_threads)
    wq.enqueue_b { sleep(0.01) }
    assert_equal(1, wq.cur_threads)
    wq.join
  end

  def test_stress
    a = []
    m = Mutex.new
    wq = SimpleWorkQueue.new(250)
    (1..1000).each do
      wq.enqueue_b do
        sleep(0.01)
        m.synchronize { a.push nil }
      end
    end
    wq.join
    assert_equal(1000, a.size)
  end

end
