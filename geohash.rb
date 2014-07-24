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
		#testet ob t an entsprechendem bit 0 oder 1 ist und setzt dies entsprechend 
		arr << (((t & 16) > 0)? "1" : "0")
		arr << (((t & 8) > 0)? "1" : "0")
		arr << (((t & 4) > 0)? "1" : "0")
		arr << (((t & 2) > 0)? "1" : "0")
		arr << (((t & 1) > 0)? "1" : "0")
	end
	return arr
end

#first idea: input bits as string 
#assumption: counting starts at the left side
#even bits are taken for the longitude bitstring
#odd bits are taken for the latitude bitstring
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
	interval = (-90.0 .. 90.0)
	mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
	mini = interval.min
	maxi = interval.max
	#err = 45.0 #error
	lat_bitstring.each_char do |c|
		if c.to_f == 1
			interval = (mean .. maxi)
			mini = mean
			mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
			maxi = interval.max
			#err = err / 2 
		else 
			interval = (mini .. mean)
			mini = interval.min
			maxi = mean
			mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
			#err = err / 2 
		end
	end
	@lat = mean
	puts "latitude: #{@lat}"
	return @lat
end

def decode_long(long_bitstring)
	@long = 0.0
	interval = (-180.0 .. 180.0)
	mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
	mini = interval.min
	maxi = interval.max
	#err = 90
	long_bitstring.each_char do |c|
		if c.to_f == 1
			interval = (mean .. maxi)
			mini = mean
			mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
			maxi = interval.max
			#err = err / 2 
		else 
			interval = (mini .. mean)
			maxi = mean
			mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
			mini = interval.min
			#err = err / 2 
		end
	end
	@long = mean
	puts "longitude: #{@long}"
	return @long
end

def decode_geohash(bitstring)
	split_bits(decode_base32(bitstring))
	decode_long(@long_bitstring)
	decode_lat(@lat_bitstring)
end
#decode_geohash("ezs42")
#decode_geohash("dqcjqcp84c6e")

#input latitude as float output bitstring
def encode_lat(lat, precision=12)
	i = 0
	@lat = ""
	interval = (-90.0 .. 90.0)
	mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
	maxi = interval.max
	mini = interval.min
	while i < precision
		if lat > mean 
			@lat += "1"
			interval = (mean .. maxi)
			mini = mean
			mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
			maxi = interval.max
		else
			@lat += "0"
			interval = (mini .. mean)
			maxi = mean
			mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
			mini = interval.min
		end
		i += 1
	end
	#puts "bitstring latitude #{@lat}"
	return @lat
end

def encode_long(long, precision=13)
	i = 0
	@long = ""
	interval = (-180.0 .. 180.0)
	mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
	maxi = interval.max
	mini = interval.min
	while i < precision
		if long > mean 
			@long += "1"
			interval = (mean .. maxi)
			mini = mean
			mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
			maxi = interval.max
		else
			@long += "0"
			interval = (mini .. mean)
			maxi = mean
			mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
			mini = interval.min
		end
		i += 1
	end
	#puts "bitstring latitude #{@long}"
	return @long
end
#encode_long(-5.60302734375)

#to do: take_bytes
def merge(long_bitstring, lat_bitstring)
	@bitstring = ""
	i = 0
	i_lat = 0
	i_long = 0
	while i < ((lat_bitstring.length) + (long_bitstring.length))
		if i % 2 == 0
			@bitstring += long_bitstring[i_long]
			#puts long_bitstring[i_long]
			i_long += 1
		else
			@bitstring += lat_bitstring[i_lat]
			i_lat += 1
		end
		i += 1
	end
	#puts @bitstring
	return @bitstring
end
#merge("0111110000000", "101111001001")

#methode ueberlegen die de gesamten bitstring in bytes aufspaltet und für jedes bin2dec und encode ufruft und dann hinterher alle wieder zusammenbastelt 
#error handling --> if bitstring.length isn#z divisible by 5 the last bits (the modulo 5 rest) is not taken
#take the bitstring and split it into strings of 5 bits
def split_bitstring(bitstring) 
	arr = []
	mini = 0
	max = mini + 4 
	maxi = (bitstring.length) - 1
	while max <= maxi
		arr << bitstring[mini .. max]
		mini += 5
		max = mini + 4 
	end
	#puts arr.inspect
	return arr
end
#split_bitstring("1000111111")

def bin2dec(bytestring)
	num = 0
	exp = 0
	i = (bytestring.length)-1 #starts at the LSD
	while i >= 0
		num += (bytestring[i].to_i) * 2**exp
		exp += 1
		i -= 1
	end
	#puts num
	return num
end
#bin2dec("1101")

def encode_base32(num) #input e.g. 13 
	lookup = { 1 => "1", 2 => "2", 3 => "3", 4 => "4", 5 => "5", 6 => "6", 7 => "7", 8 => "8", 9 => "9", 10 => "b",
		11 => "c", 12 => "d", 13 => "e", 14 => "f", 15 => "g", 16 => "h", 17 => "j", 18 => "k", 19 => "m", 20 => "n",
		21 => "p", 22 => "q", 23 => "r", 24 => "s", 25 => "t", 26 => "u", 27 => "v", 28 => "w", 29 => "x", 30 => "y", 31 => "z" }
	@hash = lookup[num]
	#puts @hash
	return @hash
end
#encode_base32(13)

def handle_hash(bitarray) #input is output from split_bitstring
	arr = []
	bitarray.each do |i|
		arr << (encode_base32(bin2dec(i)))
	end
	arr = arr.join("")
	puts arr.inspect
	return arr
end
#handle_hash(["11111", "10001"])

def encode_geohash(latitude, longitude)
	lat = encode_lat(latitude, 12)
	long = encode_long(longitude, 13)
	bitstring = merge(long, lat)
	puts bitstring
	bitarray = split_bitstring(bitstring)
	arr = []
	bitarray.each do |i|
		arr << (encode_base32(bin2dec(i)))
	end
	arr = arr.join("")
	puts arr.inspect
	return arr
end
encode_geohash(42.60498046875, -5.60302734375)
#encode_geohash(38.897, -77.036)

#wikipedia example
def test
	puts (decode_base32("ezs42") == "0110111111110000010000010")? "decode_base32 test passed" : "there's sth wrong"
	split_bits("0110111111110000010000010")
	puts ((decode_lat("101111001001") > 42) && (decode_lat("101111001001") < 43))? "decode_lat test passed" : "there's sth wrong"
	puts ((decode_long("0111110000000") > -6) && (decode_long("0111110000000") < -5))? "decode_long test passed" : "there's sth wrong" 
	puts (encode_lat(42.60498046875) == "101111001001")? "encode_lat test passed" : "there's sth wrong"
	puts (encode_long(-5.60302734375) == "0111110000000")? "encode_long test passed" : "there's sth wrong"
	puts (merge("0111110000000", "101111001001") == "0110111111110000010000010")? "merge test passed" : "there's sth wrong"
end
#test









