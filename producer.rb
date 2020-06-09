require 'securerandom'
require 'drb/drb'

DURI = 'druby://localhost:9999'

name = ARGV.first || SecureRandom.uuid

puts "got producer name: #{name}"
puts "starting thread ..."


loop do
  obj = DRbObject.new_with_uri(DURI)
  puts "obj: #{obj}"


  obj.synchronize do
    puts "generating random"
    random = SecureRandom.hex
    puts "random"
    puts "#{name} INSERTING: #{random}"
    obj << random
  end
  sleep(0.5)
end
