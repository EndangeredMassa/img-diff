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

assert = require 'assertive'
compareImages = require './compare_images'
crop = require './crop'

getError = (mismatch, tolerance, images) ->
  message = "Images are #{mismatch}% different! Tolerance was #{tolerance}."
  error = new Error(message)
  error.compareImages = images
  error

module.exports =
  imagesMatch: (image1, image2, tolerance=0.0) ->
    assert.truthy 'imagesMatch(image1, image2, tolerance=0.0) - requires image1', image1
    assert.truthy 'imagesMatch(image1, image2, tolerance=0.0) - requires image2', image2

    image1 = new Buffer(image1, 'base64') if typeof image1 == 'string'
    image2 = new Buffer(image2, 'base64') if typeof image2 == 'string'

    data = compareImages image1, image2
    mismatch = data.mismatch

    if mismatch > tolerance
      error = getError mismatch, tolerance, {
        diff: data.diff
        image1
        image2
      }
      throw error

  crop: crop

