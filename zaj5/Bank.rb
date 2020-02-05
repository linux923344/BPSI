#!/usr/bin/env ruby
require 'socket'
require 'openssl'
require 'digest'

hostname = 'localhost'
port = 5444


$sock = TCPSocket.open(hostname, port)
$sock.puts "Bank"

$liczba_par_L_R = [$sock.gets.gsub(/\n$/, '')].pack("B*").to_i
$kwota = [$sock.gets.gsub(/\n$/, '')].pack("B*").to_i


while 1
	input = [$sock.gets.gsub(/\n$/, '')].pack("B*")
	
	if input == "2"
		
		Alice_hash1 = [$sock.gets.gsub(/\n$/, '')].pack("B*")
		Alice_R1 = [$sock.gets.gsub(/\n$/, '')].pack("B*")

		Alice_R1p = [$sock.gets.gsub(/\n$/, '')].pack("B*")
		Alice_R2 = [$sock.gets.gsub(/\n$/, '')].pack("B*")
		l_Alice = [$sock.gets.gsub(/\n$/, '')].pack("B*")
		
		to_hash_Alice = Alice_R1p + Alice_R2 + l_Alice
		Alice_hash2 = Digest::SHA512.hexdigest to_hash_Alice.to_s
		
		if(Alice_R1 != Alice_R1p)
			puts "FAILTURE"
			$sock.puts "FAILTURE".unpack("B*")
		end

		if(Alice_hash1 != Alice_hash2)
			puts "FAILTURE"
			$sock.puts "FAILTURE".unpack("B*")
		end

		if(Alice_hash1 == Alice_hash2)
			puts "PASSED"
			$sock.puts "PASSED".unpack("B*")
		end
		
	end
	
	banknot_blind = [0]
	if input == "3"
		$liczba_banknotow = 0
		pom=true
		while pom == true
			msg = [$sock.gets.gsub(/\n$/, '')]#.pack("B*")
			puts msg
			if msg.pack("B*") == "END"
				pom = false
			else
				banknot_blind[$liczba_banknotow] = msg
				
				if $liczba_banknotow > 200
					puts "ERROR $liczba_banknotow = "+$liczba_banknotow.to_s
					pom=false
				end
				FileName = "banknot_"+$liczba_banknotow.to_s+"_blinded.txt"
				puts "FILE_CONTENT : \n " + banknot_blind[$liczba_banknotow].to_s.tr('["]', '')
				File.write(FileName, banknot_blind[$liczba_banknotow].to_s.tr('["]', ''))
				$liczba_banknotow = $liczba_banknotow + 1
			end
		end
		$liczba_banknotow=$liczba_banknotow-1
		puts $liczba_banknotow.inspect
		i=rand($liczba_banknotow.to_i)
		$sock.puts i.to_s.unpack("B*")
		
	
		for b in 0..$liczba_banknotow do 
			if b!=i
				puts b
				FileName = "banknot_"+b.to_s+"_blinded.txt"
				$odebrano = [$sock.gets.gsub(/\n$/, '')].pack("B*")
				$odebrano = $odebrano.tr('[ "]', '').split(",")
				if $odebrano[1].to_i != $kwota
					puts "ERROR: VALUE_IS_DIFFRENT . " + $odebrano[1].to_s + " . " + $kwota.to_s
					exit
				else 
					if ($odebrano.length)-3 != ($liczba_par_L_R.to_i)*2
						puts "Amount of par is NOT correct"
					exit
					end
				end
				puts $odebrano 
			else 
				FileName = "banknot_"+b.to_s+"_blinded.txt"
				msg_int_blinded = File.read(FileName)
				
				dsa = OpenSSL::PKey::DSA.new(2048)
				pub_key = dsa.public_key
				pub_key_der = pub_key.to_der
				
				digest = OpenSSL::Digest::SHA1.digest(msg_int_blinded)
				sig = dsa.syssign(digest)

				#$sock.puts pub_key_der.unpack("B*")
				#$sock.puts sig.unpack("B*")

			end 
		end

		$sock.puts pub_key_der.unpack("B*")
		$sock.puts msg_int_blinded.unpack("B*")
		$sock.puts sig.unpack("B*")

	end
end
