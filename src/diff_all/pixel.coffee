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

ALPHA_CHANNEL = 3

invert = (octet) ->
  255 - octet

module.exports =
  set: (image, x, y, pixel) ->
    for channel in [0..pixel.length-1]
      image.set(x, y, channel, pixel[channel])

  get: (image, x, y) ->
    return null if x > image.shape[0] - 1
    return null if y > image.shape[1] - 1

    depth = image.shape[2] - 1
    pixel = []
    for channel in [0..depth]
      bit = image.get(x, y, channel)
      pixel.push bit

    pixel

  getDiff: (image1, image2, x, y) ->
    pixel1 = @get(image1, x, y)
    pixel2 = @get(image2, x, y)

    transparentPixel = [0, 0, 0, 0]
    diffPixel = [255, 0, 255, 255] # Purple!

    if !pixel1 && !pixel2
      return [transparentPixel, false]

    if pixel1 && pixel2
      if @matches(pixel1, pixel2)
        return [pixel1, false]
      else
        return [diffPixel, true]

    pixel = pixel1 || pixel2
    pixel = @makeTransparent(pixel, 0.6)

    [pixel, true]

  makeTransparent: (pixel, percent) ->
    transparency = Math.round(percent * 255)
    pixel[ALPHA_CHANNEL] = transparency
    pixel

  matches: (pixel1, pixel2) ->
    different = false
    # pixels will be the same length
    for i in [0..pixel1.length-1]
      if pixel1[i] != pixel2[i]
        different = true
        break

    !different

  invertAlpha: (rgbaBuffer) ->
    for i in [0..rgbaBuffer.length-1]
      if (i+1) % 4 == 0
        rgbaBuffer[i] = invert(rgbaBuffer[i])
    rgbaBuffer

