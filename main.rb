require 'thread'
require 'monitor'
require 'securerandom'
require 'thwait'

class Consumer
  attr_reader :id, :condition, :own_buffer, :max_size
  def initialize(id = nil, max_size = 10)
    @id = id || SecureRandom.uuid
    @max_size = max_size
    @own_buffer = []
  end

  def consume(queue, &block)
    loop do
      if full?
        puts "consumer #{id} is full #{own_buffer.size}"
        Thread.exit
      else
        queue.synchronize do
          log_id
          val = yield(self)
          own_buffer << val
        end
      end
    end
  end

  def full?
    own_buffer.size >= max_size
  end

  def log_id
    puts "Consumer #{id}"
  end
end

class Producer
  attr_reader :id, :own_buffer, :resources_size

  def initialize(id: nil, resources_size: nil)
    @id = id || SecureRandom.uuid
    @resources_size = resources_size
    @own_buffer = []
    generate_resources(resources_size) if resources_size
  end

  def produce(queue, &block)
    loop do
      if empty?
        puts "Producer #{id} is empty!"
        Thread.exit
      else
        queue.synchronize do
          log_id
          yield(produce_val)
        end
      end
    end
  end

  def generate_resources(size)
    size.times do
      val = SecureRandom.hex
      @own_buffer << val
    end
  end

  def produce_val
    @resources_size ? @own_buffer.pop : SecureRandom.hex
  end

  def log_id
    puts "Producer #{id}"
  end

  def empty?
    @resources_size ? (@own_buffer.empty?) : false
  end
end

class ProducerConsumer
  def initialize(pthreads = 3, cthreads = 3, queue_size = 5)
    @pthreads, @cthreads = pthreads, cthreads
    @queue = SizedQueue.new(queue_size)
    @queue.extend(MonitorMixin)
    @empty_cond = @queue.new_cond
    @full_cond = @queue.new_cond
    @all_consumers_full = @queue.new_cond
    @all_producers_empty = @queue.new_cond
    @threads = []
  end

  def run(time = nil)
    producers
    consumers
    ThreadsWait.all_waits(@threads) do |thread|
      puts "GOT RESULT: #{thread}"
    end
  end

  def producers
    @pthreads.times do
      t = Thread.new do
        producer = Producer.new(resources_size: 10)
        producer.produce(@queue) do |val|
          @full_cond.wait_while { @queue.max == @queue.length }
          @queue.push(val)
          @empty_cond.signal
        end
        true
      end
      @threads << t
    end
  end

  def consumers
    @cthreads.times do
      t = Thread.new do
        consumer = Consumer.new
        consumer.consume(@queue) do |i|
          @empty_cond.wait_while { @queue.empty? }
          @all
          val = @queue.pop
          @full_cond.signal
          val
        end
      end
      @threads << t
    end
  end

  def kill_all
    @threads.each(&:join)
  end
end

pc = ProducerConsumer.new(2, 2, 10)

pc.run
pc.kill_all
