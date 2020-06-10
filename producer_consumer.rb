class ProducerConsumer
  attr_reader :consumers

  def initialize(pthreads = 3, cthreads = 3, queue_size = 5)
    @pthreads_number, @cthreads_number = pthreads, cthreads
    @queue = SizedQueue.new(queue_size)
    @queue.extend(MonitorMixin)
    @empty_cond = @queue.new_cond
    @full_cond = @queue.new_cond
    @all_consumers_full = @queue.new_cond
    @all_producers_empty = @queue.new_cond
    @threads = []
    @consumers = []
  end

  def run(time = nil)
    producers
    consumers
    ThreadsWait.all_waits(@threads)
  end

  def producers
    @pthreads = []
    @pthreads_number.times do
      t = Thread.new do
        producer = Producer.new(resources_size: 5)
        producer.produce(@queue) do |val|
          @full_cond.wait_while { @queue.max == @queue.length }
          @queue.push(val)
          @empty_cond.signal
        end
      end
      @threads << t
      @pthreads << t
    end
  end

  def consumers
    @cthreads ||= []
    @cthreads_number.times do
      t = Thread.new do
        consumer = Consumer.new
        @consumers << consumer
        consumer.consume(@queue) do
          @empty_cond.wait_while { @queue.empty? }
          val = @queue.pop
          consumer.consume_val(val)
          @full_cond.signal
        end
      end
      @threads << t
      @cthreads << t
    end
  end

  def kill_all
    @threads.each(&:join)
  end
end
