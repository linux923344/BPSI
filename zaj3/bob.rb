#!/usr/bin/env ruby

require 'prime'
require 'openssl'
require 'socket'
require 'securerandom'

sock = TCPServer.new 3000 
client = sock.accept

client.puts "Choose: des-ecb, des-ede3-cbc, aes-cbc-192, rc5-ecb, idea-ofb"
mode = client.gets.gsub(/\n$/, '')

pp=client.gets
pp=pp.chop

dh2 = OpenSSL::PKey::DH.new(pp)
dh2.generate_key!

client.puts dh2.pub_key

key=client.gets
key=key.chop
key=key.to_i

symm_key2 = dh2.compute_key(key.to_bn)

d = OpenSSL::Cipher.new(mode)
d.decrypt

case mode.strip 
when "des-ecb"
    d.key = symm_key2[0..7]
when "des-ede3-cbc"
    d.key = symm_key2[0..23]
    d.iv = iv = client.gets.gsub(/\n$/, '')
when "aes-cbc-192"
    d.key = symm_key2[0..23]
    d.iv = iv = client.gets.gsub(/\n$/, '')
when 'idea-ofb'
    d.iv = iv = client.gets.gsub(/\n$/, '')
end

message = client.gets
message.delete!("\n")
decrypted=d.update(message)+d.final

puts
puts "-----------------------------------"
puts
puts "Mode: " + mode
puts "Public: " + (dh2.pub_key).to_s
puts "Priv: " + (key).to_s
puts "Sym Key 2: " + symm_key2
puts "IV: " + iv.inspect
puts "Decypted: " + decrypted
puts
puts "-----------------------------------"


client.close
