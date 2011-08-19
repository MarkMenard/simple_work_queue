require 'lib/simple_work_queue'

10.times do |j|
  wq = SimpleWorkQueue.new(50)
  2500.times do |i|
    wq.enqueue_b do
      puts "!!!!!!!!!!!!!!!!!!!! DONE - Finished run #{j} !!!!!!!!!!!!!!!!!!!!" if i == 2499
    end
  end
  wq.join
end

puts "Finished noop test."

10.times do |j|
  wq = SimpleWorkQueue.new(100)
  500.times do |i|
    wq.enqueue_b do
      sleep rand
      puts "!!!!!!!!!!!!!!!!!!!! DONE - Finished run #{j} !!!!!!!!!!!!!!!!!!!!" if i == 499
    end
  end
  wq.join
end

# Under JRuby 1.6.3 we never get here.
puts "*********************** DONE *********************"