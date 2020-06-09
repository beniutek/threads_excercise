require 'drb/drb'
require 'monitor'

class CustomSizedQueue < SizedQueue
  def full?
    length == max
  end
end
# queue = Queue.new
DURI = 'druby://localhost:9999'
queue_size = ARGV.first || 10
queue = CustomSizedQueue.new(queue_size)
queue.extend(MonitorMixin)
puts "queue set: #{queue}"
puts "starting service under: #{DURI}"
DRb.start_service(DURI, queue)
puts "started!"
DRb.thread.join
