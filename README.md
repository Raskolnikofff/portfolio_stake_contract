Sheme how to test.
<pre>
periods     - 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30

who deposit - 0 0 0 0 0 x x x x x  xy xy xy xy xy  0  0  0  0  0 xyz..
</pre>

x=5

y=15

z=20

allReward=30000

period count = 30

reward for 1 period rp=30000/30=1000

x reward = 5 * rp+5 * rp * x/(x+y)+10 * rp * x/(x+y+z)=7500

y reward = 5 * rp * y/(x+y)+10 * rp * y/(x+y+z)=7500

z reward = 10 * rp * z/(x+y+z)=5000

unused reward = 10 * rp=10000
