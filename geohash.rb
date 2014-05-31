#outputs the bit representation 
def decode_base32(string)
	#base32 to numerical value (input char, output int)
	lookup = { "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9, "b" => 10, 
		"c" => 11, "d" => 12, "e" => 13, "f" => 14, "g" => 15, "h" => 16, "j" => 17, "k" => 18, "m" => 19, "n" => 20, 
		"p" => 21, "q" => 22, "r" => 23, "s" => 24, "t" => 25, "u" => 26, "v" => 27, "w" => 28, "x" => 29, "y" => 30, "z" => 31}
	arr = ""
	string.each_char do |c|
		t = lookup[c]
		#ternary operator: conditional? true : false 
		arr << (((t & 16) > 0)? "1" : "0")
		arr << (((t & 8) > 0)? "1" : "0")
		arr << (((t & 4) > 0)? "1" : "0")
		arr << (((t & 2) > 0)? "1" : "0")
		arr << (((t & 1) > 0)? "1" : "0")
	end
	return arr
end

#first idea: input bits as string 
def split_bits(bitstring)
	i = 0
	@long_bitstring = ""
	@lat_bitstring = ""
	while i < bitstring.length
		if i % 2 == 0
			@long_bitstring += bitstring[i]
		else
			@lat_bitstring += bitstring[i]
		end
		i += 1 	
	end
	#puts "Longitude: #{@long_bitstring}, Latitude: #{@lat_bitstring}"
	return @long_bitstring
	return @lat_bitstring
end

def decode_lat(lat_bitstring)
	@lat = 0.0
	i = 0
	min = -90.0
	max = +90.0
	mid = 0.0
	err = 45.0
	while i < lat_bitstring.length
		if (lat_bitstring[i]).to_f == 1
			min = mid
			mid = min + (max - min) / 2
			err = err / 2 
		else 
			max = mid
			mid = min + (max - min) / 2
			err = err / 2 
		end
		i += 1 
	end
	@lat = mid
	puts "decoded latitude: #{@lat}"
	return @lat
end

def decode_long(long_bitstring)
	@long = 0.0
	i = 0
	min = -180.0
	max = +180.0
	mid = 0.0
	err = 90
	while i < long_bitstring.length
		if (long_bitstring[i]).to_f == 1
			min = mid
			mid = min + (max - min) / 2
			err = err / 2 
		else 
			max = mid
			mid = min + (max - min) / 2
			err = err / 2 
		end
		i += 1 
	end
	@long = mid
	puts "decoded latitude: #{@long}"
	return @long
end

#wikipedia example
def test
	puts (decode_base32("ezs42") == "0110111111110000010000010")? "decode_base32 test passed" : "there's sth wrong"
	split_bits("0110111111110000010000010")
	puts ((decode_lat("101111001001") > 42) && (decode_lat("101111001001") < 43))? "decode_lat test passed" : "there's sth wrong"
	puts ((decode_long("0111110000000") > -6) && (decode_long("0111110000000") < -5))? "decode_long test passed" : "there's sth wrong" 
end

#test

def decode_geohash(bitstring)
	split_bits(decode_base32(bitstring))
	decode_long(@long_bitstring)
	decode_lat(@lat_bitstring)
end

decode_geohash("ezs42")








