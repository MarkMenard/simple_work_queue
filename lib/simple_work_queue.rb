##
# = Name
# SimpleWorkQueue
#
# == Description
# This file contains an implementation of a work queue structure.
#
# == Version
# 1.0.0
#
# == Author
# Miguel Fonseca <fmmfonseca@gmail.com>
# Mark Menard <mark.menard.tny@gmail.com>
#
# == Copyright
# Copyright 2009-2010 Miguel Fonseca
# Copyright 2011 Mark Menard
#
# == License
# MIT (see LICENSE file)
#

require 'java'

##
# = SimpleWorkQueue
#
# == Description
# A simple work queue, designed to coordinate work between a producer and a pool of worker threads.
# SimpleWorkQueue is a fork of WorkQueue by Miguel Fonseca that has been simplified and made to work
# with JRuby using a non-blocking queue from the Java Concurrency framework.
#
# SimpleWorkQueue unlike WorkQueue does not support time outs (unneeded because SimpleWorkQueue uses 
# a non-blocking queue), or limits on the number of queued jobs. If you need these features under
# JRuby you will need to find a different solution.
#
# == Usage
#  wq = SimpleWorkQueue.new
#  wq.enqueue_b { puts "Hello from the SimpleWorkQueue" }
#  wq.join
#
class SimpleWorkQueue

  ##
  # Creates a new work queue with the desired parameters.
  #
  #  wq = SimpleWorkQueue.new(5)
  #
  def initialize(max_threads=nil)
    self.max_threads = max_threads
    @threads = []
    @threads_lock = Mutex.new
    @tasks = java.util.concurrent.ConcurrentLinkedQueue.new
    @threads.taint
    @tasks.taint
    self.taint
  end

  ##
  # Returns the maximum number of worker threads.
  # This value is set upon initialization and cannot be changed afterwards.
  #
  #  wq = SimpleWorkQueue.new()
  #  wq.max_threads		#=> Infinity
  #  wq = SimpleWorkQueue.new(1)
  #  wq.max_threads		#=> 1
  #
  def max_threads
    @max_threads
  end

  ##
  # Returns the current number of worker threads.
  # This value is just a snapshot, and may change immediately upon returning.
  #
  #  wq = SimpleWorkQueue.new(10)
  #  wq.cur_threads		#=> 0
  #  wq.enqueue_b {}
  #  wq.cur_threads		#=> 1
  #
  def cur_threads
    @threads.size
  end

  ##
  # Returns the current number of queued tasks.
  # This value is just a snapshot, and may change immediately upon returning.
  #
  #  wq = SimpleWorkQueue.new(1)
  #  wq.enqueue_b { sleep(1) }
  #  wq.cur_tasks		#=> 0
  #  wq.enqueue_b {}
  #  wq.cur_tasks		#=> 1
  #
  def cur_tasks
    @tasks.size
  end

  ##
  # Schedules the given Proc for future execution by a worker thread.
  # If there is no space left in the queue, waits until space becomes available.
  #
  #  wq = SimpleWorkQueue.new(1)
  #  wq.enqueue_p(Proc.new {})
  #
  def enqueue_p(proc, *args)
    @tasks.add([proc,args])
    spawn_thread
    self
  end

  ##
  # Schedules the given Block for future execution by a worker thread.
  # If there is no space left in the queue, waits until space becomes available.
  #
  #  wq = SimpleWorkQueue.new(1)
  #  wq.enqueue_b {}
  #
  def enqueue_b(*args, &block)
    @tasks.add([block,args])
    spawn_thread
    self
  end

  ##
  # Waits until the tasks queue is empty and all worker threads have finished.
  #
  #  wq = SimpleWorkQueue.new(1)
  #  wq.enqueue_b { sleep(1) }
  #  wq.join
  #
  def join
    cur_threads.times { dismiss_thread }
    @threads.dup.each { |thread| thread.join if thread }
    self
  end

  ##
  # Stops all worker threads immediately, aborting any ongoing tasks.
  #
  #  wq = SimpleWorkQueue.new(1)
  #  wq.enqueue_b { sleep(1) }
  #  wq.stop
  #
  def stop
    @threads.dup.each { |thread| thread.exit.join }
    @tasks.clear
    self
  end

  private

  ##
  # Sets the maximum number of worker threads.
  #
  def max_threads=(value)
    raise ArgumentError, "the maximum number of threads must be positive" if value and value <= 0
    @max_threads = value || 1.0/0
  end

  ##
  # Enrolls a new worker thread.
  # The request is only carried out if necessary.
  #
  def spawn_thread
    if cur_threads < max_threads and cur_tasks > 0
      @threads_lock.synchronize {
        @threads << Thread.new do
          begin
            work()
          ensure
            @threads_lock.synchronize { @threads.delete(Thread.current) }
          end
        end
      }
    end
  end

  ##
  # Instructs an idle worker thread to exit.
  # The request is only carried out if necessary.
  #
  def dismiss_thread
    @tasks << [Proc.new { Thread.exit }, nil] if cur_threads > 0
  end

  ##
  # Repeatedly process the tasks queue.
  #
  def work
    loop do
      begin
        proc, args = @tasks.poll
        if proc
          proc.call(*args)
        else
          break
        end
      rescue Exception
        # suppress exception
      end
      break if cur_threads > max_threads
    end
  end

end