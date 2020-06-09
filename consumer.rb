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
