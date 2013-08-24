#!/usr/bin/env ruby
# Talk To Me -- tell me something and I'll tell you if I understand it
 
require 'rubygems'
require 'treetop'
puts 'Loaded Treetop with no problems...'

Treetop.load 'email_list'
puts 'Loaded email list grammar with no problems...'
 
parser = EmailListParser.new

print "You say: "; what_you_said = gets
what_you_said.strip! # remove the newline at the end
 
if result = parser.parse(what_you_said)
  puts "I say yes! I understand!"
  puts "You said the email name #{result.email_name.text_value}"
  puts "You said the email addr #{result.bracketed_email.text_value}"
else
  puts "I say no, I don't understand."
  puts parser.failure_reason
end

