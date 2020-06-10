require 'thread'
require 'monitor'
require 'securerandom'
require 'thwait'
require './producer.rb'
require './consumer.rb'
require './producer_consumer.rb'


pthreads, cthreads, queue_size = ARGV
pc = ProducerConsumer.new(pthreads.to_i || 2, cthreads.to_i || 2, queue_size.to_i || 5)

pc.run
pc.kill_all
