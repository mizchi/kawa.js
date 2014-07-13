console.log '---------', new Date

property = (obj, key, {get, set}) ->
  Object.defineProperty obj, key, {get, set}

extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

class EventEmitter
  off: (f) =>
    @events ?= []
    if f
      if @events.indexOf(f) > -1
        @events.splice @events.indexOf(f), 1
    else
      @events.length = 0

  trigger: ->
    @events ?= []
    for ev in @events
      ev(@_val)

  onChange: (f) ->
    @events ?= []
    @events.push f

# MergeStream<T>
class MergeStream
  extend @::, EventEmitter::
  # @merge :: Strems<T>[] * (T -> T) -> Stream<T>
  constructor: (initial, @streams, @reducer)->
    @_val = initial

    @_onDispose = []

    for s in @streams then do (s) =>
      cb = =>
        values = @streams.map (s) ->
          if s.disposed then throw new Error 'child disposed'
          s.value()

        @_val = @reducer values, @_val
        @trigger()
      s.onChange cb
      @_onDispose.push -> s.off cb

  value: -> @_val

  dispose: ->
    @disposed = true
    for fn in @_onDispose then fn()
    delete @_onDispose
    delete @events
    delete @reducer
    delete @_val
    Object.freeze @

# Stream<T, U>
class Stream
  @merge: (initial, streams, fn) ->
    new MergeStream initial, streams, fn

  extend @::, EventEmitter::
  # constructor :: U * (T -> U) -> Stream<T, U>
  constructor: (initial, @reducer)->
    @disposed = false
    @events = []
    @reducer ?= (v) -> v
    @_val = initial

  dispose: ->
    @disposed = true
    delete @events
    delete @reducer
    delete @_val
    Object.freeze @

  # value :: () -> U
  value: -> @_val

  # addSource :: T -> U
  addSource: (val) ->
    prev = @_val
    next = @reducer val, @_val
    @_val = next
    if next isnt prev
      @trigger()
    @_val

s1 = new Stream 0
s2 = new Stream 0, (newVal, lastVal) -> lastVal + newVal
s3 = Stream.merge 0, [s1, s2], ([v1, v2], last) -> v1 * v2 + last
s4 = Stream.merge 0, [s3], ([v3]) -> v3+1

#s1.onChange (v) -> console.log 's1',v
#s2.onChange (v) -> console.log 's2',v
s3.onChange (v) -> console.log 's3',v
s4.onChange (v) -> console.log 's4',v

s1.addSource 10
s2.addSource 3
# s3.dispose()
s2.addSource 5
s1.addSource -10

