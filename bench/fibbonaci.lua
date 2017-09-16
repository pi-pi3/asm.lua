
fib = 1
x = 0
y = 1
n = 1000000

function fibonnaci()
    fib = x + y
    x, y = y, fib
end

for i=n, 0, -1 do
    --print(fib)
    fibonnaci()
end
