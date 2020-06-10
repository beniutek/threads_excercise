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
      self
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
