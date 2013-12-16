assert = require 'assertive'
diffAll = require '../../lib/diff_all'

RGBA_CHANNELS = 4

describe 'diff_all', ->
  beforeEach ->
    @height = 5
    @width = 5
    @image =
      data: []
      height: @height
      width: @width
    @image2 =
      data: []
      height: @height
      width: @width

  it 'returns a blank diff', ->
    {diff, mismatch} = diffAll(@image, @image2)
    assert.equal 0, mismatch

  it 'returns a real diff', ->
    @image2.data = [1,0,0,0]
    {diff, mismatch} = diffAll(@image, @image2)
    assert.equal 4, mismatch

