require 'thread'
require 'monitor'
require 'securerandom'
require 'thwait'
require './producer.rb'
require './consumer.rb'
require './producer_consumer.rb'

# pobieramy argumenty wejściowe
i , j, k = ARGV

# upewniamy się, że każdy argument będzie miał wartość > 0
pthreads = i.to_i > 0 ? i.to_i : 2
cthreads = j.to_i > 0 ? j.to_i : 2
queue_size = k.to_i > 0 ? k.to_i : 10

pc = ProducerConsumer.new(pthreads, cthreads, queue_size)

pc.run
pc.kill_all
