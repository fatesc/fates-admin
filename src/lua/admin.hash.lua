SHA256 = function(mes)
	local con = 4294967296
	local ch = {
		1779033703,
		3144134277,
		1013904242,
		2773480762,
		1359893119,
		2600822924,
		528734635,
		1541459225
	}
	local k = {1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298}
	 local function bit(obj, bit)
		return obj % (bit * 2) >= bit
	end
	 local function Or(ca, cb)
		local new = 0
		for i = 0, 32 do
			new = new + ((bit(ca, 2 ^ i) or bit(cb, 2 ^ i)) and 2 ^ i or 0)
		end
		return new
	end
	 local function rshift(obj, times)
		times = times or 1
		return math.floor(obj * .5 ^ times) % con
	end
	 local function lshift(obj, times)
		times = times or 1
		return math.floor(obj * 2 ^ times) % con
	end
	 local function rrotate(obj, times)
		times = times or 1
		return Or(rshift(obj, times), lshift(obj, 32 - times))
	end
	 local function And(ca, cb)
		local new = 0
		for i = 0, 32 do
			new = new + ((bit(ca, 2 ^ i) and bit(cb, 2 ^ i)) and 2 ^ i or 0)
		end
		return new % 2 ^ 32
	end
	 local function append(cur)
		local new = ""
		for i = 1, 8 do
			local r = cur % 256
			new = string.char(r) .. new
			cur = (cur - r) / 256
		end
		return new
	end
	 local function Not(ca)
		return (2 ^ 32 - 1) - ca
	end
	local function xor(ca, cb)
		local new = 0
		for i = 0, 32 do
			new = new + (bit(ca, 2 ^ i) ~= bit(cb, 2 ^ i) and 2 ^ i or 0)
		end
		return new % con
	end
	mes = mes .. "\128" .. ("\0"):rep(64 - ((#mes + 9) % 64)) .. append(#mes * 8)
	local Chunks = {}
	for i = 1, #mes, 64 do
		table.insert(Chunks, mes:sub(i, i + 63))
	end
	for _, Chunk in next, Chunks do
		local w = {}
		for i = 0, 15 do
			w[i] = (function()
				local n = 0
				for q = 1, 4 do
					n = n * 256 + Chunk:byte(i * 4 + q)
				end
				return n
			end)()
		end
		for i = 16, 63 do
			local s0 = xor(xor(rrotate(w[i - 15], 7), rrotate(w[i - 15], 18)), rshift(w[i - 15], 3))
			local s1 = xor(xor(rrotate(w[i - 2], 17), rrotate(w[i - 2], 19)), rshift(w[i - 2], 10))
			w[i] = (w[i - 16] + s0 + w[i - 7] + s1) % con
		end
		local a, b, c, d, e, f, g, h = unpack(ch)
		for i = 0, 63 do
			local s0 = xor(xor(rrotate(a, 2), rrotate(a, 13)), rrotate(a, 22))
			local s1 = xor(xor(rrotate(e, 6), rrotate(e, 11)), rrotate(e, 25))
			local t0 = h + s1 + xor(And(e, f), And(Not(e), g)) + k[i + 1] + w[i]
			local t1 = s0 + xor(xor(And(a, b), And(a, c)), And(b, c))
			h = g
			g = f
			f = e
			e = (d + t0) % con
			d = c
			c = b
			b = a
			a = (t0 + t1) % con
		end
		ch[1] = (ch[1] + a) % con
		ch[2] = (ch[2] + b) % con
		ch[3] = (ch[3] + c) % con
		ch[4] = (ch[4] + d) % con
		ch[5] = (ch[5] + e) % con
		ch[6] = (ch[6] + f) % con
		ch[7] = (ch[7] + g) % con
		ch[8] = (ch[8] + h) % con
	end
	return ("%08x%08x%08x%08x%08x%08x%08x%08x"):format(unpack(ch))
end