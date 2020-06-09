require 'drb/drb'

MURI = "druby://localhost:1234"

obj = DRbObject.new_with_uri(MURI)

puts obj.locked?
