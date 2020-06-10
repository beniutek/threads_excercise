class Consumer
  attr_reader :id, :condition, :own_buffer, :max_size

  def initialize(id = nil, max_size = 5)
    @id = id || SecureRandom.uuid
    @max_size = max_size
    @own_buffer = []

  end

  def consume(queue, &block)
    loop do
      if full?
        puts "consumer #{id} is full"
        Thread.exit
      else
        queue.synchronize do
          log_id
          yield
        end
      end
      self
    end
  end

  def full?
    own_buffer.size >= max_size
  end

  def consume_val(val)
    own_buffer << val
  end

  def log_id
    puts "Consumer #{id}"
  end

  def to_s
    @own_buffer.to_s
  end
end
