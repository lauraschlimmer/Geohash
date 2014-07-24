<h1>Geohash</h1>

<p>Decode and encode geohashes based on <a href="http://en.wikipedia.org/wiki/Geohash">http://en.wikipedia.org/wiki/Geohash</a>
</p>

<p><strong>Decode geohash</strong> </br>
	<code >geohash1 = Geohash.new 0, 0, "ezs42" </code></br>
	<code>geohash1.geohash_decode</code>
</p>

<p><strong>Encode geohash</strong></br>
	<code>geohash2 = Geohash.new (-5.60302734375), 42.60498046875 </code></br>
	<code>geohash2.geohash_encode</code>
</p>




<h1>TODO</h1> 
<ul>
	<li>check if there's a bug when encoding negative lat, long values </li>
	<li>proper initialize method (parameters as dictionary)</li>
	<li>implement distance calculation</li>
	<li>write array functions new</li>
	<li>initialize with precision and interval boundary</li>
</ul>