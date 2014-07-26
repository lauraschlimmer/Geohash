class Geohash

#dict with parameters -> if isset --> search how to give properties to lat and long like precision and interval_bound
  def initialize(lat = 0, long = 0, geohash= '')
    @lat = lat
    @long = long
    @geohash = geohash
  end

  def geohash_encode
    encode_geohash(@lat, @long)
  end

  def geohash_decode
    decode_geohash(@geohash)
  end

  def calculate_distance(geohash1, geohash2)
    @length = ([geohash1.length, geohash2.length]).min
    @i = 0
    @t = 0
    while @i < @length do
      if geohash1[@i] == geohash2[@i]
        @t = @t+1
        @i = @i+1
      else
        @i = @length
      end
    end
    #puts @t
    #precision => distance from adjacent cell in meters
    lookup_dist = {1 => 5003530, 2 => 625441, 3 => 123264, 4 => 19545, 5 => 3803, 
      6 => 610, 7 => 118, 8 => 19, 9 => 3.71, 10 => 0.6}
    distance = lookup_dist[@t]
    puts distance
  end


private

  #base 32 -> base 2 
  def decode_base32(string)
    lookup = { "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9, "b" => 10, 
      "c" => 11, "d" => 12, "e" => 13, "f" => 14, "g" => 15, "h" => 16, "j" => 17, "k" => 18, "m" => 19, "n" => 20, 
      "p" => 21, "q" => 22, "r" => 23, "s" => 24, "t" => 25, "u" => 26, "v" => 27, "w" => 28, "x" => 29, "y" => 30, "z" => 31}
    arr = ""
    string.each_char do |c|
      t = lookup[c]
      arr << (((t & 16) > 0)? "1" : "0")
      arr << (((t & 8) > 0)? "1" : "0")
      arr << (((t & 4) > 0)? "1" : "0")
      arr << (((t & 2) > 0)? "1" : "0")
      arr << (((t & 1) > 0)? "1" : "0")
    end
    return arr
  end

 
  #counting starts at the left side, even bits are taken for the longitude bitstring, odd bits are taken for the latitude bitstring
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
    return @long_bitstring
    return @lat_bitstring
  end


#decodes the bitstring reresentation of the latitude's or longitude's bitstring and returns the coordinates as floats
#interval_bound as positive float, 180.0 for long and 90.0 for lat
  def decode_bitstring(bitstring, interval_bound)
    @coord = 0.0
    interval = (-interval_bound .. interval_bound)
    mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
    mini = interval.min
    maxi = interval.max
    bitstring.each_char do |c|
      if c.to_f == 1
        interval = (mean .. maxi)
        mini = mean
        mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
        maxi = interval.max
      else 
        interval = (mini .. mean)
        maxi = mean
        mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
        mini = interval.min
      end
    end
    @coord = mean
    return @coord
  end


  def decode_geohash(bitstring)
    split_bits(decode_base32(bitstring))
    @long = decode_bitstring(@long_bitstring, 180.0)
    puts "longitude: #{@long}"
    @lat = decode_bitstring(@lat_bitstring, 90.0)
    puts "latitude: #{@lat}"
  end


  #input latitude as float output bitstring, float precision (lat = 12, long = 13)
  def encode_coord(coord, precision, interval_bound)
    i = 0
    @bitstring = ""
    interval = (-interval_bound .. interval_bound)
    mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
    maxi = interval.max
    mini = interval.min
    while i < precision
      if coord > mean 
        @bitstring += "1"
        interval = (mean .. maxi)
        mini = mean
        mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
        maxi = interval.max
      else
        @bitstring += "0"
        interval = (mini .. mean)
        maxi = mean
        mean = interval.min + (((interval.max) - (interval.min)) / 2.0)
        mini = interval.min
      end
      i += 1
    end
    return @bitstring
  end

  #merge the latitude and longitude bitstring, in doing so the bitstrings characters 
  #are placed alternately starting with the long bitstring's first character 
  def merge(long_bitstring, lat_bitstring)
    @bitstring = ""
    i = 0
    i_lat = 0
    i_long = 0
    while i < ((lat_bitstring.length) + (long_bitstring.length))
      if i % 2 == 0
        @bitstring += long_bitstring[i_long]
        i_long += 1
      else
        @bitstring += lat_bitstring[i_lat]
        i_lat += 1
      end
      i += 1
    end
    return @bitstring
  end


  #error handling --> if bitstring.length isn't divisible by 5 the last bits (the modulo 5 rest) is not taken
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
    return arr
  end

 #starts at the LSD
  def bin2dec(bytestring)
    num = 0
    exp = 0
    i = (bytestring.length)-1
    while i >= 0
      num += (bytestring[i].to_i) * 2**exp
      exp += 1
      i -= 1
    end
    return num
  end


  def encode_base32(num) 
    lookup = { 1 => "1", 2 => "2", 3 => "3", 4 => "4", 5 => "5", 6 => "6", 7 => "7", 8 => "8", 9 => "9", 10 => "b",
      11 => "c", 12 => "d", 13 => "e", 14 => "f", 15 => "g", 16 => "h", 17 => "j", 18 => "k", 19 => "m", 20 => "n",
      21 => "p", 22 => "q", 23 => "r", 24 => "s", 25 => "t", 26 => "u", 27 => "v", 28 => "w", 29 => "x", 30 => "y", 31 => "z" }
    @hash = lookup[num]
    return @hash
  end


  def handle_hash(bitarray) #input is output from split_bitstring
    arr = []
    bitarray.each do |i|
      arr << (encode_base32(bin2dec(i)))
    end
    arr = arr.join("")
    puts arr.inspect
    return arr
  end

  def encode_geohash(latitude, longitude)
    lat = encode_coord(latitude, 27, 90.0)
    long = encode_coord(longitude, 28, 180.0)
    bitstring = merge(long, lat)
    puts bitstring
    bitarray = split_bitstring(bitstring)
    handle_hash(bitarray)
  end





end

geohash1 = Geohash.new 0, 0, "ezs42" 
geohash1.geohash_decode

geohash2 = Geohash.new (-5.60302734375), 42.60498046875 
geohash2.geohash_encode

geohash2.calculate_distance("kz3456789", "kzn217zzzzz")



