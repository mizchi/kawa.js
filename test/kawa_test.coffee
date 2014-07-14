Kawa = require '../kawa'
{ok} = require 'assert'

console.log '---------', new Date
s1 = new Kawa.Stream 0
s2 = new Kawa.Stream 0, (newVal, lastVal) -> lastVal + newVal
s3 = Kawa.merge 0, [s1, s2], ([v1, v2], last) -> v1 * v2 + last

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