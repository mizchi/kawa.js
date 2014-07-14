extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

Kawa = {}
if module?.exports = Kawa
else window.Kawa = Kawa

class EventEmitter
  off: (f) =>
    @events ?= []
    if f
      if @events.indexOf(f) > -1
        @events.splice @events.indexOf(f), 1
    else
      @events.length = 0

  triggerChange: (v = null) ->
    @events ?= []
    for ev in @events
      ev(v ? @_val)

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
        @triggerChange()
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

class WaiterStream
  constructor: (@streams, @fullfilled, @callback, once = false)->
    @_onDispose = []

    for s in @streams then do (s) =>
      cb = =>
        values = @streams.map (s) =>
          if s.disposed then throw new Error 'child disposed'
          s.value()

        if @fullfilled(values)
          @callback(values)
          if once
            @dispose()

      s.onChange cb
      @_onDispose.push -> s.off cb

  dispose: ->
    for f in @_onDispose then f()
    delete @_onDispose
    delete @streams
    delete @fullfilled
    delete @callback
    Object.freeze @

Kawa.when = (streams, fullfilled, fn) ->
  new WaiterStream streams, fullfilled, fn

Kawa.once = (streams, fullfilled, fn) ->
  new WaiterStream streams, fullfilled, fn, true

Kawa.merge = (initial, streams, fn) ->
  new MergeStream initial, streams, fn

# Stream<T, U>
class Kawa.Stream
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

  reset: (@_val) -> @triggerChange()

  # value :: () -> U
  value: -> @_val

  # addSource :: T -> U
  addSource: (val) ->
    prev = @_val
    next = @reducer val, @_val
    @_val = next
    if next isnt prev
      @triggerChange()
    @_val

class Kawa.Junction
  extend @::, EventEmitter::
  constructor: (initial, @props)->
    @_val = initial
    @disposed = false
    streams = (s for key, s of @props)
    @_merger = Kawa.merge initial, streams, =>
      @triggerChange(@value())

  dispose: ->
    @disposed = true
    @_merger.dispose()
    delete @events
    delete @props
    delete @_val
    Object.freeze @

  value: ->
    obj = {}
    for k, v of @props
      obj[k] = v.value()
    obj

console.log '---', new Date
p1 = new Kawa.Stream 0
p2 = new Kawa.Stream 0
chunk = new Kawa.Junction {p1: p1.value(), p2: p2.value()}, {p1: p1, p2: p2}

chunk.onChange (v) -> console.log 'chunk', v
p1.addSource(1)