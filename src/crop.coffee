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

RGBA_CHANNELS = 4

ndarray = require 'ndarray'
parsePng = require './parse_png'
{pick} = require 'underscore'

Pixel = require './diff_all/pixel'
{Png} = require 'png'


getView = (image, y1, x1, height, width) ->
  # trim top-left
  view = image.lo(y1, x1, 0)

  #trim bottom-right
  view.hi(height, width, 0)

crop = (image, y1, x1, height, width) ->
  view = getView(image, y1, x1, height, width)

  cropped = []

  for i in [0..view.shape[0]-1]
    for j in [0..view.shape[1]-1]
      cropped.push view.get(i, j, 0)
      cropped.push view.get(i, j, 1)
      cropped.push view.get(i, j, 2)
      cropped.push view.get(i, j, 3)

  {
    data: cropped
    height: view.shape[0]
    width: view.shape[1]
  }

module.exports = (imageData, section) ->
  imageData = new Buffer(imageData, 'base64') if typeof imageData == 'string'
  image = parsePng imageData

  validate(image, section)

  shape = [image.height, image.width, RGBA_CHANNELS]
  image = ndarray image.data, shape

  encode crop(image, section.y, section.x, section.height, section.width)

encode = (imageData) ->
  height = imageData.height
  width = imageData.width
  data = new Buffer(imageData.data)

  # the alpha is inverted for some reason
  data = Pixel.invertAlpha(data)

  png = new Png(data, width, height, 'rgba')
  png.encodeSync().toString('base64')

validate = (image, section) ->
  sectionProperties = JSON.stringify section
  imageProperties = JSON.stringify (pick image, ['height', 'width'])
  oob = new Error "Crop section #{sectionProperties} out of bounds for image #{imageProperties}"

  throw oob if section.x < 0
  throw oob if section.y < 0
  throw oob if section.width < 0
  throw oob if section.height < 0

  throw oob if image.height < (section.y + section.height)
  throw oob if image.width < (section.x + section.width)

