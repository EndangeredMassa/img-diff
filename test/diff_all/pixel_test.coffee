assert = require 'assertive'
ndarray = require 'ndarray'
{clone} = require 'underscore'
Pixel = require '../../lib/diff_all/pixel'

RGBA_CHANNELS = 4

pixelEquals = (pixel1, pixel2) ->
  assert.equal pixel1[0], pixel2[0]
  assert.equal pixel1[1], pixel2[1]
  assert.equal pixel1[2], pixel2[2]
  assert.equal pixel1[3], pixel2[3]

describe 'diff-all#pixel', ->
  beforeEach ->
    @height = 5
    @width = 5
    @image = ndarray [], [@height, @width, RGBA_CHANNELS]
    @image2 = ndarray [], [@height, @width, RGBA_CHANNELS]
    @pixel = [10, 20, 30, 40]

  it '#makeTransparent makes a pixel transparent', ->
    transparentPixel = Pixel.makeTransparent @pixel, 0.5
    pixelEquals transparentPixel, [10, 20, 30, 128]

  it '#invertAlpha inverts the alpha channel', ->
    invertedPixel = Pixel.invertAlpha @pixel
    pixelEquals invertedPixel, [10, 20, 30, 215]

  describe '#set', ->
    it 'pushes data to 0,0', ->
      x = 0
      y = 0

      Pixel.set(@image, x, y, @pixel)

      pixel = @image.data[0..3]
      pixelEquals pixel, [10, 20, 30, 40]

    it 'pushes data to a real offeset', ->
      x = 1
      y = 1

      Pixel.set(@image, x, y, @pixel)

      xOffset = (@width-1) * RGBA_CHANNELS + (x * RGBA_CHANNELS)
      yOffset = y * RGBA_CHANNELS
      offset = xOffset + yOffset

      pixel = @image.data[offset..offset+3]
      pixelEquals pixel, [10, 20, 30, 40]

  describe '#get', ->
    it 'returns null if x out of bounds', ->
      pixel = Pixel.get @image, 100, 1
      assert.falsey pixel

    it 'returns null if y out of bounds', ->
      pixel = Pixel.get @image, 1, 100
      assert.falsey pixel

    it 'returns a pixel', ->
      Pixel.set(@image, 1, 1, @pixel)
      pixel = Pixel.get @image, 1, 1
      pixelEquals pixel, @pixel

  describe '#getDiff', ->
    it 'returns same pixel', ->
      Pixel.set @image, 1, 1, @pixel
      [diffPixel, mismatched] = Pixel.getDiff @image, @image, 1, 1
      pixelEquals @pixel, diffPixel
      assert.equal false, mismatched

    it 'returns diff pixel', ->
      expectedDiff = [255, 0, 255, 255]
      Pixel.set @image, 1, 1, @pixel
      Pixel.set @image2, 1, 1, [1,2,3,4]

      [diffPixel, mismatched] = Pixel.getDiff @image, @image2, 1, 1

      pixelEquals expectedDiff, diffPixel
      assert.equal true, mismatched

    it 'returns transparent pixel', ->
      expectedDiff = [0, 0, 0, 0]
      Pixel.set @image, 1, 1, @pixel
      Pixel.set @image2, 1, 1, @pixel

      [diffPixel, mismatched] = Pixel.getDiff @image, @image2, 6, 6

      pixelEquals expectedDiff, diffPixel
      assert.equal false, mismatched

  describe '#matches', ->
    it 'is true for same pixels', ->
      assert.truthy Pixel.matches @pixel, @pixel

    it 'is different for different pixels', ->
      assert.falsey Pixel.matches @pixel, [1,2,3,4]

