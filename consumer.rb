class Consumer
  attr_reader :id, :condition, :own_buffer, :max_size

  # argumenty wejściowe
  # id -> identyfikator dla obiektu, domyślnie typ uuid
  # max_size -> maksymalna liczba pobranych danych
  def initialize(id = nil, max_size = 5)
    @id = id || SecureRandom.uuid
    @max_size = max_size
    @own_buffer = []

  end

  # metoda będzie w nieskończoność konsumowała dane z queue
  # jeśli @max_size != nil i @own_buffer jest zapełniony to zamiast tego
  # wątek będzie zakańczany
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
    return false if @max_size.nil?
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
