require 'thread'
require 'monitor'
require 'securerandom'
require 'thwait'

class ProducerConsumer
  def initialize(pthreads = 3, cthreads = 3, queue_size = 5)
    @pthreads, @cthreads = pthreads, cthreads
    @queue = SizedQueue.new(queue_size)
    @queue.extend(MonitorMixin)
    @empty_cond = @queue.new_cond
    @full_cond = @queue.new_cond
    @threads = []
  end

  def run
    producers
    consumers
    ThreadsWait.all_waits(@threads)
  end

  def producers
    @pthreads.times do
      puts "setting producer"
      t = Thread.new do
        val = SecureRandom.uuid
        Thread.current.thread_variable_set(:id, val)
        puts "created producer: #{val}"
        loop do
          @queue.synchronize do
            @full_cond.wait_while { @queue.max == @queue.length }
            val = SecureRandom.hex
            @queue.push(val)
            puts "#{id} producing #{val}, queue length: #{@queue.length}"
            @empty_cond.signal
          end
        end
      end
      @threads << t
      puts "finished setting producer"
    end
  end

  def consumers
    @cthreads.times do
      puts "setting consumer"
      t = Thread.new do
        loop do
          @queue.synchronize do
            @empty_cond.wait_while { @queue.empty? }
            val = @queue.pop
            puts "Consumed #{val}, queue length #{@queue.length}"
            @full_cond.signal
          end
        end
      end
      @threads << t
      puts "finished setting consumer"
    end
  end

  def id
    Thread.current.thread_variable_get(:id)
  end
end

pc = ProducerConsumer.new(2, 2, 10)
pc.run
