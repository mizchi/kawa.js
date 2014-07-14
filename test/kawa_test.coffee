Kawa = require '../kawa'

console.log '---------', new Date
s1 = new Kawa.Stream 0
s2 = new Kawa.Stream 0, (newVal, lastVal) -> lastVal + newVal
s3 = Kawa.merge 0, [s1, s2], ([v1, v2], last) -> v1 * v2 + last
# s4 = Stream.merge 0, [s3], ([v3]) -> v3+1

s1.onChange (v) -> console.log 's1',v
s2.onChange (v) -> console.log 's2',v
s3.onChange (v) -> console.log 's3',v
# s4.onChange (v) -> console.log 's4',v

Kawa.when [s1, s2], (([v1, v2]) -> v1 is v2), ([v1, v2]) -> console.log 'fullfilled'
Kawa.once [s1, s2], (([v1, v2]) -> v1 is v2), ([v1, v2]) -> console.log 'once'

s1.addSource 1
s2.addSource 1
# s3.dispose()
# s2.addSource 5
# s1.addSource -10

# n = true
# setInterval ->
#   s1.addSource if n then 1 else -1
#   n = !n
# , 1000
