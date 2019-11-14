#!/usr/bin/env ruby

require 'prime'
require 'openssl'
require 'socket'
require 'securerandom'

message = File.read("message.txt")
sock = TCPSocket.new("localhost",3000)

dsa = OpenSSL::PKey::DSA.new(2048)
pub_key = dsa.public_key
pub_key_der = pub_key.to_der

digest = OpenSSL::Digest::SHA1.digest(message)
sig = dsa.syssign(digest)

sock.puts pub_key_der.unpack("B*")
sock.puts message.unpack("B*")
sock.puts sig.unpack("B*")

#puts pub_key_der.inspect
#puts message.inspect
#puts sig.inspect
puts dsa.public_key
puts dsa.sysverify(digest, sig)