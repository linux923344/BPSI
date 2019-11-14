#!/usr/bin/env ruby

require 'prime'
require 'openssl'
require 'socket'
require 'securerandom'

sock = TCPServer.new 3000 
client = sock.accept

pub_keyA = [client.gets.gsub(/\n$/, '')].pack("B*")
messageA = [client.gets.gsub(/\n$/, '')].pack("B*")
sigA = [client.gets.gsub(/\n$/, '')].pack("B*")

#puts pub_keyA.inspect
#puts messageA.inspect
#puts sigA.inspect

dsa = OpenSSL::PKey::DSA.new(pub_keyA)
digest = OpenSSL::Digest::SHA1.digest(messageA)
puts dsa.sysverify(digest, sigA)