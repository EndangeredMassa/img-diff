###
Copyright (c) 2013, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

{Png} = require 'png'
ndarray = require 'ndarray'
Pixel = require './pixel'
{min, max} = Math

RGBA_CHANNELS = 4

buildImageData = (image) ->
  ndarray image.data, [image.height, image.width, RGBA_CHANNELS]

module.exports = (image1, image2) ->
  image1 = buildImageData image1
  image2 = buildImageData image2
  diffImage = createDiffBase(image1, image2)

  mismatchCount = 0

  maxX = diffImage.shape[0] - 1
  maxY = diffImage.shape[1] - 1

  for x in [0..maxX]
    for y in [0..maxY]
      [pixel, mismatched] = Pixel.getDiff(image1, image2, x, y)
      Pixel.set(diffImage, x, y, pixel)

      if mismatched
        mismatchCount++

  diffImage =
    height: diffImage.shape[0]
    width: diffImage.shape[1]
    data: new Buffer(diffImage.data)
  diff = encode(diffImage)

  pixels = getTotalPixels(image1, image2)
  mismatch = ( mismatchCount / pixels ) * 100
  mismatch = Math.round(mismatch * 100) / 100

  {
    diff
    mismatch
  }

getTotalPixels = (image1, image2) ->
  x1 = image1.shape[0]
  y1 = image1.shape[1]

  x2 = image2.shape[0]
  y2 = image2.shape[1]

  if (x1 >= x2) && (y1 >= y2)
    return x1 * y1
  if (x2 >= x1) && (y2 >= y1)
    return x2 * y2

  maxX = max(x1, x2)
  minX = min(x1, x2)
  maxY = max(y1, y2)
  minY = min(y1, y2)

  totalPixels = maxX * maxY
  emptySpace = (maxX - minX) * (maxY - minY)

  totalPixels - emptySpace

createDiffBase = (image1, image2) ->
  width = max(image1.shape[1], image2.shape[1])
  height = max(image1.shape[0], image2.shape[0])

  ndarray [], [height, width, RGBA_CHANNELS]

setDiffPixel = (diff, index) ->
  diff.data[index] = 255
  diff.data[index+1] = 0
  diff.data[index+2] = 255
  diff.data[index+3] = 255 # force alpha to visible

encode = (image) ->
  # the alpha is inverted for some reason
  image.data = Pixel.invertAlpha(image.data)

  png = new Png(image.data, image.width, image.height, 'rgba')
  png.encodeSync()

