#!/usr/bin/env ruby
require 'socket'
require 'openssl'
require 'securerandom'


$hostname = 'localhost'
$port = 5444
$Ia = 47163
$liczba_banknotow = 10
$liczba_par_L_R = 10

$sock = TCPSocket.open($hostname, $port)
$sock.puts "Alice"

# 1 protokół podziału sekretu (Rij, Lij; Lij = Ia xor Rij; Rij => <1,100>)//////////////////////////////////////////////////////////////////////////////
kwota = 1000
j=0
R=[0]
L=[0]

$sock.puts $liczba_par_L_R.to_s.unpack("B*")
$sock.puts kwota.to_s.unpack("B*")

while j<$liczba_banknotow

	for i in 0..$liczba_par_L_R-1 do
	
	
		R[i] = rand(100)
		# 2 protokół zobowiązania bitowego dla każdego Rij i Lij (niezależnie) ==> Rij = (yij, rij)..........................
		$sock.puts "2".unpack("B*")
	
		R1 = SecureRandom.random_number(1000..9999).to_s
		R2 = SecureRandom.random_number(1000..9999).to_s
		
		
		to_hash = R1 + R2 + R[i].to_s
		
		hash = Digest::SHA512.hexdigest to_hash.to_s
		
		$sock.puts hash.unpack("B*")
		$sock.puts R1.unpack("B*")
		
		$sock.puts R1.unpack("B*")
		$sock.puts R2.unpack("B*")
		$sock.puts R[i].to_s.unpack("B*")
		
		response = [$sock.gets.gsub(/\n$/, '')].pack("B*")
		puts response
		
		if response == "FAILTURE"
			p = "ERROR (Bank reboot)"
		end
		
		
		
		L[i] = $Ia ^ R[i]
		# 2 protokół zobowiązania bitowego dla każdego Rij i Lij (niezależnie) ==> Rij = (yij, rij).......................
		$sock.puts "2".unpack("B*")
	
		R1 = SecureRandom.random_number(1000..9999).to_s
		R2 = SecureRandom.random_number(1000..9999).to_s
		
		
		to_hash = R1 + R2 + L[i].to_s
		
		hash = Digest::SHA512.hexdigest to_hash.to_s
		
		$sock.puts hash.unpack("B*")
		$sock.puts R1.unpack("B*")
		
		$sock.puts R1.unpack("B*")
		$sock.puts R2.unpack("B*")
		$sock.puts L[i].to_s.unpack("B*")
		
		response = [$sock.gets.gsub(/\n$/, '')].pack("B*")
		puts response
		
		if response == "FAILTURE"
			p = "ERROR (Bank reboot)"
		end
		
		
	end
	banknot = [j, kwota, rand(999999)]
	banknot = banknot + L + R
	FileName = "banknot_"+j.to_s+".txt"
	File.write(FileName, banknot.join("\n"))
	j=j+1
end
puts p


#3 ZAKRYWANIE BANKTONU 
k = rand(1..1000)


pom=0
msg=["0"]
$sock.puts "3".unpack("B*")
while pom<$liczba_banknotow
	FileName = "banknot_"+pom.to_s+".txt"
	msg[pom]=File.read(FileName)
	msg[pom]=msg[pom].split("\n")
	msg_int=msg[pom].join.to_i
	puts msg[pom].join.to_i

	msg_int_blinded=(msg_int**k) % 28 
	
	$sock.puts msg_int_blinded#.unpack("B*")
	
	pom=pom+1
end
$sock.puts "END".unpack("B*")

i=[$sock.gets.gsub(/\n$/, '')].pack("B*").to_i


for b in 0..$liczba_banknotow do 
	if b!=i
		$sock.puts msg[b].to_s.unpack("B*")
	end 
end	

pub_keyA = [$sock.gets.gsub(/\n$/, '')].pack("B*")
msg_int_blinded_signed = [$sock.gets.gsub(/\n$/, '')].pack("B*")
sigA = [$sock.gets.gsub(/\n$/, '')].pack("B*")

puts msg_int_blinded_signed.inspect

dsa = OpenSSL::PKey::DSA.new(pub_keyA)
digest = OpenSSL::Digest::SHA1.digest(msg_int_blinded_signed)
puts "Pierwsze True"
puts dsa.sysverify(digest, sigA)

d = (-k)

msg_int_unblinded = (msg_int_blinded_signed.to_i**d) % 28

dsa1 = OpenSSL::PKey::DSA.new(pub_keyA)
digest1 = OpenSSL::Digest::SHA1.digest(msg_int_unblinded.to_s)
puts "Drugie True"
puts dsa.sysverify(digest1, sigA)


#bankkey = [$sock.gets.gsub(/\n$/, '')].pack("B*")
#verify(msg_int_blinded_signed.to_s, msg_int_blinded.to_s, bankkey)

# sm = sm' * r^-1 (mod n)
#msg_int_signed = unblind(msg_int_blinded_signed, r, key)


# 4 wysyłanie banknotów do banku
# 5 bank prosi o odkrycie banknotów za wyjątkiem banknotu i
# 6 bank podpisuje banknoty
# 7 Alice odkrywa podpis pod banktotem i
