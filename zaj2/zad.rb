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
require 'securerandom'
require 'digest'

# .inspect - for check white characters

def printAll
  puts "------------------------------------------------------"
  puts "Mode: " + $mode.inspect
  puts "Hash: " + $hash.inspect
  puts "Number 1: " + $randomnumber1.inspect
  puts "Number 2: " + $randomnumber2.inspect
  puts "Choice: " + $choice.inspect
  puts "------------------------------------------------------"
end


$randomnumber1 = rand 1..100000000
$randomnumber2 = rand 1..100000000

sock = TCPSocket.new('150.254.79.126', 3000)
puts sock.gets 
$mode = gets
puts sock.gets
$choice = gets.gsub(/\n$/, '')

$allNeed = $randomnumber1.to_s + $randomnumber2.to_s + $choice.to_s

case $mode.strip 
when 'SHA512'
 $hash = Digest::SHA512.hexdigest $allNeed.to_s
when 'SHA256'
 $hash = Digest::SHA256.hexdigest $allNeed.to_s
when 'RIPEMD160'
 $hash = Digest::RIPEMD160.hexdigest $allNeed.to_s
when 'MD5'
 $hash = Digest::MD5.hexdigest $allNeed.to_s
else
  puts "You gave me #{$mode} -- I have no idea what to do with that."
  exit
end

sock.puts $mode.unpack("B*")
sock.puts $hash.unpack("B*")
sock.puts $randomnumber1
sock.puts $choice
sock.puts $randomnumber1
sock.puts $randomnumber2
sock.close

printAll
