Kawa = require '../kawa'
{ok} = require 'assert'

describe 'Kawa', ->
  beforeEach ->
    @stream = null

  afterEach ->
    @stream?.dispose()

  it 'Kawa.Stream id', (done) ->
    @stream = new Kawa.Stream 0
    ok @stream.value() is 0
    @stream.onChange (v) =>
      ok @stream.value() is 1
      done()
    @stream.addSource 1

  it 'Kawa.Stream with reducer', (done) ->
    @stream = new Kawa.Stream 0, (newVal, lastVal) -> newVal + lastVal
    ok @stream.value() is 0
    @stream.onChange (v) =>
      if @stream.value() is 5 then done()

    @stream.addSource 2
    @stream.addSource 3

  it 'Kawa.merge', (done) ->
    s1 = new Kawa.Stream 0
    s2 = new Kawa.Stream 0
    @stream = Kawa.merge 0, [s1, s2], ([v1, v2]) -> v1 + v2
    @stream.onChange (v) ->
      if v is 4 then done()

    s1.addSource 2
    s2.addSource 2

  it 'Kawa.when', (done) ->
    s1 = new Kawa.Stream 0
    s2 = new Kawa.Stream 0
    Kawa.when [s1, s2], (([v1, v2]) -> v1 is v2 * 2), -> done()
    s1.addSource 2
    s2.addSource 1

  it 'Kawa.once', (done) ->
    s1 = new Kawa.Stream 0
    s2 = new Kawa.Stream 0
    Kawa.once [s1, s2], (([v1, v2]) -> v1 is v2 * 2), -> done()
    s1.addSource 2
    s2.addSource 1

  it 'Kawa.Junction', (done) ->
    p1 = new Kawa.Stream 0
    p2 = new Kawa.Stream 0
    junction = new Kawa.Junction {}, {p1: p1, p2: p2}
    junction.onChange (v) ->
      ok v.p1 is 1
      ok v.p2 is 0
      done()
    p1.addSource(1)