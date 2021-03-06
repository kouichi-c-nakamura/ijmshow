# **NOTE: `ijmshow` is not recommended** any more because of its dependency on `IJM`. **Consider using [`copytoImagePlus`](https://github.com/kouichi-c-nakamura/copytoImagePlus) instead.**


# ijmshow
A MATLAB function. A wrapper of `net.imagej.matlab.ImageJMATLABCommands.show()` (or `IJM.show()`) to support opening a MATLAB array as 5D hyperstack in ImageJ

- [`copytoImagePlus`](https://github.com/kouichi-c-nakamura/copytoImagePlus) does the same job without requiring the Java object `IJM`
- [`copytoImg`](https://github.com/fiji/fiji/blob/master/scripts/copytoImg.m) and [`copytoImgPlus` ](https://github.com/fiji/fiji/blob/master/scripts/copytoImgPlus.m) are bundled with Fiji and work in a similar way but using ImageJ2 API and objects.



## Opening an image in ImageJ from within MATLAB

https://imagej.net/MATLAB_Scripting#Running_ImageJ_within_MATLAB



`ImageJ-MATLAB` as part of Fiji installation allows us to open an ImageJ instance from within MATLAB and we can transfer an array of  data using `IJM.show('name')` (from MATLAB to ImageJ) and `IJM.getDataset()` and `IJM.getDatasetAs('name')`(from ImageJ to MATLAB).

Although these are useful, the current version of ImageJ-MATLAB's  `IJM.show('name')` has the following limitations:

1. `IJM.show('name')` will flip over the X and Y axes of array between MATLAB and ImageJ
2. `IJM.show('name')` cannot handle multidimensional (>2D) images properly; All the third and higher dimensions are piled as the fifth dimension of a 5D hyperstack. This is a real pain if you are handling more than one channel, one slice, or one frame of images, as is often the case.
3. No matter what data type the original MATLAB array is, it is shown in ImageJ as `int32` data type. Conversion of the datatype to bytes (`uint8`) or short ( `uint16`) in ImageJ can involve scaling of numeric values, resulting in unexpected changes of pixel values, unless carefully avoided.

`ijmshow` is a wrapper of  `net.imagej.matlab.ImageJMATLABCommands.show()` (or `IJM.show()`) and offers solutions to the above issues. Until someone can fix the `IJM.show()` properly some day, `ijmshow` will be useful for interaction between MATLAB and ImageJ.

1. X and Y axes can be corrected (eg, using `YXCZT` by default) or left as default behaviour (eg. `XYCZT`)
2. The`dimorder` input argument can specify the dimensions for channels (C), slices (Z), and frames (T) (by default `YXCZT`)
3. Numeric values of pixel data are maintained while the image type is converted to 16 bit or 8 bit depending on the data type of the original MATLAB array.
4. You can access `IJM` in the base Workspace from within a MATLAN function. You can open a MATLAB array in a function with ImageJ.



## Syntax

```matlab
imp = ijmshow(I)
imp = ijmshow(I,dimorder)
imp = ijmshow(____,'Param',value)

% Param can be 'NewName' or 'FrameInterval'
```



## MATLAB code examples



### RGB image

```matlab
>> addpath '/Applications/Fiji.app/scripts'
>> ImageJ

>> I = imread('peppers.png') % the size of I is 384 x 512 x 3 in MATLAB

>> IJM.show('I')
```

This will end up X and Y flipped over, and channels are not recognized as channels (instead, it is interpreted as time frames).

![Image005](Image005.png)

```matlab
>> imp = ijmshow(I)
>> imp = ijmshow(I,'YXC') % equivalent as above
>> imp = ijmshow(I,'YXCZT') % equivalent as above
```

![Image004](Image004.png)

```matlab
>> imp = ijmshow(I,'XYC') % X an Y flipped over
```

![Image001](Image001.png)

### 5D hyperstack


```matlab
>> imp = IJ.openImage("http://imagej.nih.gov/ij/images/Spindly-GFP.zip");
>> imp.show();
>> imp
```

```
imp =
img["mitosis.tif" (-1132), 16-bit, 171x196x2x5x51]
```

The image has 171 X, 196 Y, 2 channels (C), 5 slices (Z), and 51 frames (T).

![Image002](Image002.png)

```matlab
>> IJM.getDatasetAs('I');

>> size(I) 
```

```
ans =
   171   196     2     5    51
```
Note that X and Y have already been flipped over by `IJM.getDatasetAs('I')`

```matlab
>> class(I)
```

```
ans =
    'double'
```
Note that the data type is `double` rather than `uint16`.

```matlab
>> I16 = uint16(I); % convert to uint16
>> IJM.show('I16') 
>> imp2 = ij.IJ.getImage()
```

```
imp2 =
img["" (-1136), 32-bit, 171x196x1x1x510]
```

`IJM.show()` will flip X and Y again, so back to normal X and Y.  However, the third to fifth dimensions of the image are all piled in the fifth dimension as 510 time frames (T). The image is in 32 bit type.



![Image006](Image006.png)




```matlab
>> imp3 = ijmshow(I,'XYCZT')
```

```
imp3 =
img["" (-1180), 16-bit, 171x196x2x5x51]
```

 `'XYCZT'` will accept the flipped over X and Y as input. Now it is shown as 2 channels (C), 5 slices (Z) and 51 frames (T) as expected. Image type is 16bit.  The image looks brighter because of the difference in `DisplayRange` setting, but the numeric values were identical to the original.

![Image003](Image003.png)



### `ijmshow_test`

This is a `matlab.unittest.TestCase` subclass and verify the numeric values and dimensions of the `ImagePlus` objects in ImageJ opened by `ijmshow`.



### Issues

+ 12bit data is not well supported or tested
+ `FrameInterval` may not be properly set, because File Info... does not show the Frame Interval.
+ `Display Ranges` needs to be set separately. It's possible to implement an option to automatically set Display Ranges from the min to the max of each channel. It's not clear what `CompositeImage.resetDisplayRanges()` does.
+ `IJM.show(name)` appear to have a problem with handling large image data.
+ [`copytoImagePlus`](https://github.com/kouichi-c-nakamura/copytoImagePlus) does the same job without requiring the Java object `IJM`
+ [`copytoImg`](https://github.com/fiji/fiji/blob/master/scripts/copytoImg.m) and [`copytoImgPlus` ](https://github.com/fiji/fiji/blob/master/scripts/copytoImgPlus.m) are bundled with Fiji and work in a similar way but using ImageJ2 API and objects.



### Contacts

Kouichi C. Nakamura, Ph.D.

kouichi.c.nakamura@gmail.com

MRC Brain Network Dynamics Unit, Department of Pharmacology, University of Oxford

