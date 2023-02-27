local function lastDigits(n, amount)
	local tsn = tostring(n)
	local a, b = tsn:find(".*%.")
    if not a or not b then return n end
	return tostring(tsn:sub(1, b + amount))
end

print(lastDigits(1.34443333,2))