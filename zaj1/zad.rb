#!/usr/bin/env ruby

#
# Klient wysyla jakiego szyfrowania uzywa, klucz, wiadomosc 
#
# Created: Marcin Wozniak
# Last edit: 11-04-2019
#

require 'openssl'
require 'socket'

def putsAllThingsWithIV
  puts "Encrypt: " + $mode 
  puts "IV: " + $iv
  puts "Key: " + $key
  puts "Message: " + $message
  puts ""
  puts "Decrypted message: " + $encrypted
end

def putsAllThingsOutWithIV
  puts "Encrypt: " + $mode
  puts "Key: " + $key
  puts "Message: " + $message
  puts ""
  puts "Decrypted message: " + $encrypted
end

def sendDataIVOutWithIV
  sock = TCPSocket.new('localhost', 3000)
  sock.puts $mode
  sock.puts $key
  sock.puts $encrypted
  sock.close
end 

def sendDataIVWithIV
  sock = TCPSocket.new('localhost', 3000)
  sock.puts $mode 
  sock.puts $iv 
  sock.puts $key
  sock.puts $encrypted
  sock.close
end 

$mode = ARGV[0]
$message = File.read("message.txt")

if ARGV.empty?
  puts "Argument is empty\n\nYou can use:"
  puts "  * des-ecb"
  puts "  * 3des-cbc"
  puts "  * idea-ofb"
  puts "  * aes-cbc-192"
  puts "  * rc5-ecb"
  puts ""
end

if $mode == "des-ecb"
  c = OpenSSL::Cipher.new('des-ecb')
  c.encrypt
  $key = c.random_key
  $encrypted = c.update($message) + c.final
  
  sendDataIVOutWithIV
  putsAllThingsOutWithIV

elsif $mode == "3des-cbc"
  c = OpenSSL::Cipher.new('DES-EDE3-CBC')
  c.encrypt
  $iv = c.random_iv
  $key = c.random_key
  $encrypted = c.update($message) + c.final

  sendDataIVWithIV
  putsAllThingsWithIV 

elsif  $mode == "aes-cbc-192"
  c = OpenSSL::Cipher::AES.new(128, 'CBC')
  c.encrypt 
  $iv = c.random_iv
  $key = c.random_key
  $encrypted = c.update($message) + c.final
   
  sendDataIVWithIV
  putsAllThingsWithIV

elsif  $mode == "rc5-ecb"
  c = OpenSSL::Cipher.new('RC5-ECB')
  c.encrypt 
  $iv = c.random_iv
  $key = c.random_key
  $encrypted = c.update($message) + c.final
   
  sendDataIVWithIV
  putsAllThingsWithIV

elsif  $mode == "idea-ofb"
  c = OpenSSL::Cipher.new('idea-ofb')
  c.encrypt 
  $iv = c.random_iv
  $key = c.random_key
  $encrypted = c.update($message) + c.final
   
  sendDataIVWithIV
  putsAllThingsWithIV
  
end 

server.close
