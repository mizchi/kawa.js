# 川

`kawa.js` is deadly-simple reactive programming library inspired by bacon.js.

```
npm install mizchi/kawa
```

```
bower install mizchi/kawa
```

## Features

- No dependencies
- Simplest API
- Memory safe disposal features

## How to use

Simple identity stream.

```coffee
idStream = new Kawa.Stream 0
idStream.value() #=> current value: 0
idStream.onChange (v) =>
  console.log v

idStream.addSource 1 # 1
idStream.addSource 2 # 2
```

Stream with reducer.

```coffee
sumStream = new Kawa.Stream 0, (v, sum) -> v + sum
sumStream.onChange (v) => console.log v
sumStream.addSource 1 # 1
sumStream.addSource 2 # 3
```

Merge streams

```coffee
s1 = new Kawa.Stream 0
s2 = new Kawa.Stream 0
merged = Kawa.merge 0, [s1, s2], ([v1, v2], last) -> v1 + v2
merged.onChange (v) -> console.log 'merged:', v

s1.addSource 2 # -> merged: 2
s2.addSource 2 # -> merged: 4
```

Fire callback when statements are fullfilled.

```coffee
s1 = new Kawa.Stream 0
s2 = new Kawa.Stream 0

Kawa.when [s1, s2], (([v1, v2]) -> v1 is v2 * 2), -> console.log 'fullfilled!'
s1.addSource 2
s2.addSource 1
```

`Kawa.once` has same arguments but only once.

All stream has `dispose` to dispose interal callback

```coffee
s1 = new Kawa.Stream 0
s2 = new Kawa.Stream 0
merged = Kawa.merge 0, [s1, s2], ([v1, v2], last) -> v1 + v2
waiter = Kawa.when [s1, s2], (([v1, v2]) -> v1 is v2 * 2), -> console.log 'fullfilled!'

# ...

merged.dispose()
s1.dispose()
s2.dispose()
waiter.dispose()
```

## APIs

- Kawa.Stream
  - Kawa.Stream.prototype.addStream(val)
  - Kawa.Stream.prototype.onChange(callback)
  - Kawa.Stream.prototype.dispose()
  - Kawa.Stream.prototype.reset(val)
- Kawa.merge(initial, streams, (values[, last]) -> v )
- Kawa.wait
- Kawa.once

