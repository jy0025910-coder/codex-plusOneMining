-- Exact non-negative decimal integers. Runtime state and saves use decimal strings.
local Big = {}
function Big.IsValid(value)
    return type(value) == "string" and #value <= 60 and value:match("^%d+$") ~= nil
end
function Big.Normalize(value)
    assert(Big.IsValid(value), "Expected a non-negative decimal integer")
    local result = value:gsub("^0+", "")
    return result == "" and "0" or result
end
function Big.Compare(a, b)
    a, b = Big.Normalize(a), Big.Normalize(b)
    if #a ~= #b then return #a > #b and 1 or -1 end
    if a == b then return 0 end
    return a > b and 1 or -1
end
function Big.Add(a, b)
    local output, carry = {}, 0
    local i, j = #a, #b
    while i > 0 or j > 0 or carry > 0 do
        local x = i > 0 and tonumber(a:sub(i,i)) or 0
        local y = j > 0 and tonumber(b:sub(j,j)) or 0
        local sum = x + y + carry
        table.insert(output, 1, tostring(sum % 10))
        carry = math.floor(sum / 10)
        i -= 1; j -= 1
    end
    return Big.Normalize(table.concat(output))
end
function Big.Subtract(a, b)
    if Big.Compare(a,b) <= 0 then return "0" end
    local output, borrow, j = {}, 0, #b
    for i = #a, 1, -1 do
        local digit = tonumber(a:sub(i,i)) - borrow - (j > 0 and tonumber(b:sub(j,j)) or 0)
        borrow = digit < 0 and 1 or 0
        if digit < 0 then digit += 10 end
        table.insert(output, 1, tostring(digit))
        j -= 1
    end
    return Big.Normalize(table.concat(output))
end
function Big.Multiply(a, factor)
    assert(type(factor) == "number" and factor >= 0 and factor <= 100000000 and factor % 1 == 0, "Invalid integer factor")
    local output, carry = {}, 0
    for i = #a, 1, -1 do
        local product = tonumber(a:sub(i,i)) * factor + carry
        table.insert(output, 1, tostring(product % 10))
        carry = math.floor(product / 10)
    end
    while carry > 0 do
        table.insert(output, 1, tostring(carry % 10))
        carry = math.floor(carry / 10)
    end
    return Big.Normalize(table.concat(output))
end
function Big.Divide(a, divisor)
    local output, remainder = {}, 0
    assert(divisor >= 1 and divisor <= 100000000 and divisor % 1 == 0)
    for i = 1, #a do
        local value = remainder * 10 + tonumber(a:sub(i,i))
        table.insert(output, tostring(math.floor(value/divisor)))
        remainder = value % divisor
    end
    return Big.Normalize(table.concat(output)), remainder
end
function Big.Power(factor, exponent)
    local result = "1"
    for _ = 1, exponent do result = Big.Multiply(result,factor) end
    return result
end
function Big.Format(value)
    local text = Big.Normalize(tostring(value))
    if #text <= 3 then return text end
    local suffix = {"","K","M","B","T","P","E","Z","Y","R","Q"}
    local index = math.floor((#text-1)/3)
    if index >= #suffix then return text:sub(1,3).."e"..tostring(#text-3) end
    local leading = #text-index*3
    local whole, fraction = text:sub(1,leading), text:sub(leading+1,leading+1)
    return whole..(fraction~="0" and ("."..fraction) or "")..suffix[index+1]
end
return Big
