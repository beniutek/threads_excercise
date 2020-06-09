require 'securerandom'
require 'thread'

def get_input(storage = [])
  val = gets.chomp
  storage << val
end

def get_val_from_buff(buffer = [], time = 1)
  sleep(time)
  buffer.pop
end

def insert_val_into_buff(buffer = [], val = nil, time = 1.1)
  sleep(time)
  buffer << SecureRandom.hex
end

queue =
queue.extend(MonitorMixin)
full_condition = queue.new_cond
empty_condition = queue.new_cond


producer = Thread.new do
  print "THREAD NEW"

  loop do
    queue.synchronize do
      empty_condition.wait_while { queue.empty? }
      val = get_val_from_buff(queue)
      print "POP! #{val}"
    end
  end
end
