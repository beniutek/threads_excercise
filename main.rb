require 'thread'
require 'monitor'
require 'securerandom'
require 'thwait'
require './producer.rb'
require './consumer.rb'
require './producer_consumer.rb'



pc = ProducerConsumer.new(2, 2, 10)

pc.run
pc.kill_all
