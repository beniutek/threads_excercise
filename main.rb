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
    # return self if full?

    loop do
      # return self if full?

      queue.synchronize do
        log_id
        val = yield(self)
        own_buffer << val
      end
    end
  end

  def full?
    own_buffer.size == max_size
  end

  def log_id
    puts "Consumer #{id}"
  end
end

class Producer
  attr_reader :id, :own_buffer, :resouces_size

  def initialize(id = nil, resouces_size = nil)
    @id = id || SecureRandom.uuid
    @resouces_size = resouces_size
    @own_buffer = []
    generate_resources(resouces_size) if resouces_size
  end

  def produce(queue, &block)
    loop do
      log_id
      queue.synchronize do
        yield(produce_val)
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
end

class ProducerConsumer
  def initialize(pthreads = 3, cthreads = 3, queue_size = 5)
    @pthreads, @cthreads = pthreads, cthreads
    @queue = SizedQueue.new(queue_size)
    @queue.extend(MonitorMixin)
    @empty_cond = @queue.new_cond
    @full_cond = @queue.new_cond
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
        producer = Producer.new
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
