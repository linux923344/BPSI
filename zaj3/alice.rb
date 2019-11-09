#!/usr/bin/env ruby

require 'prime'
require 'openssl'
require 'socket'
require 'securerandom'


message = File.read("message.txt")

dh1=OpenSSL::PKey::DH.new(2048)
dh1.generate_key!
der = dh1.public_key.to_der

sock = TCPSocket.new("localhost",5632)
puts sock.gets  
mode = gets.gsub(/\n$/, '')
sock.puts mode

sock.puts der
sock.puts dh1.pub_key

key=sock.gets
key=key.chop
key=key.to_i

symm_key1 = dh1.compute_key(key.to_bn)

c = OpenSSL::Cipher.new(mode)
c.encrypt

case mode.strip 
when "des-ecb"
    c.key = symm_key1[0..7]
when "des-ede3-cbc"
    c.key = symm_key1[0..23]
    iv = c.iv = SecureRandom.random_bytes(8)
    sock.puts iv
when "aes-cbc-192"
    c.key = symm_key1[0..23]
    iv = c.iv = SecureRandom.random_bytes(16)
    sock.puts iv
when "idea-ofb"
    iv = c.iv = SecureRandom.random_bytes(8)
    sock.puts iv
end

encrypted = c.update(message) + c.final
sock.puts encrypted

puts
puts "-----------------------------------"
puts
puts "Mode: " + mode
puts "Public: " + (dh1.pub_key).to_s
puts "Priv: " + (key).to_s
puts "Sym Key 1: " + symm_key1
puts "IV: " + iv.inspect
puts "Encypted: " + encrypted
puts
puts "-----------------------------------"

sock.close 
