# img-diff

Get the difference between two images
with minimal dependencies.
It depends only on `libpng`.

Warning: img-diff is experimental.
You can help us improve it by testing
it and contributing!

Keep up to date with changes
by checking the
[releases](https://github.com/groupon-testium/img-diff/releases).

## usage

Install: `npm install img-diff`

### Diff

```coffee
{imagesMatch} = require 'img-diff'
tolerance = 0.0 # percent allowed to be different
image1 = '' # base64 png string
image2 = '' # base64 png string
imagesMatch image1, image2, tolerance
```

If the images don't match and are outside the tolerance,
an error is thrown that contains both images
as well as a diff image.
The diff image can be saved to disk
in order to see the difference.

### Crop

```coffee
{crop} = require 'img-diff'
image = '' # base64 png string
section =
  x: 10
  y: 10
  width: 100
  height: 100
croppedImage = crop image, section
```

