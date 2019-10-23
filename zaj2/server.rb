#!/usr/bin/env ruby

#  ____  ____  ____ ___           _____   _       _   ____
# | __ )|  _ \/ ___|_ _|         |__  /  / \     | | |___ \
# |  _ \| |_) \___ \| |   _____    / /  / _ \ _  | |   __) |
# | |_) |  __/ ___) | |  |_____|  / /_ / ___ \ |_| |  / __/
# |____/|_|   |____/___|         /____/_/   \_\___/  |_____|
#

#
# Last edit: 23-10-2019
# Created by: Marcin Wozniak
#

require 'openssl'
require 'socket'
require 'digest'

# .inspect - for check white characters

def printAll

  if $hash==$hashNow and $randomnumber11==$randomnumber1
    $result = $choice.to_i^$choiceNow.to_i
  end

  puts "------------------------------------------------------"
  puts "Mode: " + $mode.inspect
  puts "Hash: " + $hash.inspect
  puts "Number 1: " + $randomnumber1.inspect
  puts "Number 2: " + $randomnumber2.inspect
  puts "Choice: " + $choice.inspect
  puts "HashNow: " + $hashNow.inspect
  puts "ChoiceNow: " + $choiceNow.inspect
  puts ""
  puts "Result: " + $result.to_s
  puts "------------------------------------------------------"
end

while true
  server = TCPServer.new(3000)
  client = server.accept  
  
  client.puts "Choose: SHA512, SHA256, RIPEMD160, MD5"
  client.puts "Choose 0 or 1?"
  
  $mode = [client.gets.gsub(/\n$/, '')].pack("B*")
  $hash = [client.gets.gsub(/\n$/, '')].pack("B*")
  $randomnumber1 = client.gets.gsub(/\n$/, '')
  $choice = client.gets.gsub(/\n$/, '')
  puts "Choose 0 or 1?"
  $choiceNow = gets.gsub(/\n$/, '')
  $randomnumber11 = client.gets.gsub(/\n$/, '')
  $randomnumber2 = client.gets.gsub(/\n$/, '')
  
  $allNeed = $randomnumber11.to_s + $randomnumber2.to_s + $choice.to_s

case $mode.strip 
 when 'SHA512'
  $hashNow = Digest::SHA512.hexdigest $allNeed.to_s
 when 'SHA256'
  $hashNow = Digest::SHA256.hexdigest $allNeed.to_s
 when 'RIPEMD160'
  $hashNow = Digest::RIPEMD160.hexdigest $allNeed.to_s
 when 'MD5'
  $hashNow = Digest::MD5.hexdigest $allNeed.to_s
 else
   puts "You gave me #{$mode} -- I have no idea what to do with that."
   exit
end

  printAll

  server.close
end
