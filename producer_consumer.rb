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
       puts "GOT RESULT:"
       pp thread
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
