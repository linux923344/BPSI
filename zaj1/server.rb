#!/usr/bin/env ruby

#
# Server, ktory odbiera dane i odszyfrowuje wiadmosc
#
# Created: Marcin Wozniak
# Last edit: 11-04-2019
#

require 'openssl'
require 'socket'

def putsAllThingsWithIV
  puts "Decrypt: " + $mode 
  puts "IV: " + $iv
  puts "Key: " + $key
  puts "Message: " + $message
  puts ""
  puts "Decrypted message: " + $decrypted
end  

def putsAllThingsOutWithIV
  puts "Decrypt: " + $mode
  puts "Key: " + $key
  puts "Message: " + $message
  puts ""
  puts "Decrypted message: " + $decrypted
end

server = TCPServer.open(3000)
client = server.accept 

$mode = client.gets.gsub(/\n$/, '')


if $mode == "des-ecb"
  $key = client.gets
  $message = client.gets

  d = OpenSSL::Cipher.new('des-ecb')
  d.decrypt
  d.key = $key.gsub(/\n$/, '')
  $decrypted = d.update($message.gsub(/\n$/, '')) + d.final 

  putsAllThingsOutWithIV

elsif $mode == "3des-cbc" 
  $iv = client.gets.gsub(/\n$/, '')
  $key = client.gets.gsub(/\n$/, '') 
  $message = client.gets

  d = OpenSSL::Cipher.new('DES-EDE3-CBC')
  d.decrypt
  d.iv = $iv
  d.key = $key.gsub(/\n$/, '')
  $decrypted = d.update($message.gsub(/\n$/, '')) + d.final 
  
  putsAllThingsWithIV
  
elsif $mode == "aes-cbc-192" 
  $iv = client.gets.gsub(/\n$/, '')
  $key = client.gets.gsub(/\n$/, '') 
  $message = client.gets

  d = OpenSSL::Cipher::AES.new(128, 'CBC')
  d.decrypt
  d.iv = $iv
  d.key = $key.gsub(/\n$/, '')
  $decrypted = d.update($message.gsub(/\n$/, '')) + d.final 
  
  putsAllThingsWithIV

elsif $mode == "rc5-ecb" 
  $iv = client.gets.gsub(/\n$/, '')
  $key = client.gets.gsub(/\n$/, '') 
  $message = client.gets

  d = OpenSSL::Cipher.new('RC5-ECB')
  d.decrypt
  d.iv = $iv
  d.key = $key.gsub(/\n$/, '')
  $decrypted = d.update($message.gsub(/\n$/, '')) + d.final 
  
  putsAllThingsWithIV

elsif $mode == "idea-ofb" 
  $iv = client.gets.gsub(/\n$/, '')
  $key = client.gets.gsub(/\n$/, '') 
  $message = client.gets

  d = OpenSSL::Cipher.new('idea-ofb')
  d.decrypt
  d.iv = $iv
  d.key = $key.gsub(/\n$/, '')
  $decrypted = d.update($message.gsub(/\n$/, '')) + d.final 
  
  putsAllThingsWithIV

end

server.close
