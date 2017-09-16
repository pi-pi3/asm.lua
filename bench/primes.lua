
local numbers = {}
local n = 60000

for i = 1, n do
    numbers[i] = i
end

for i = 2, math.floor(math.sqrt(n)) do
    local a = 2
    while i * a <= n do
        numbers[i*a] = -1
        a = a + 1
    end
end

for i = 1, n do
    if numbers[i] > 0 then
        print(numbers[i])
    end
end
