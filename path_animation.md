#Animating views along a curved path
##2 approaches:

Prior to iOS 7, if you wanted to animate an image along a curved path, you had to use Core animation and create a `CAKeyframeAnimation`. 

A new UIView method, `animateKeyframesWithDuration:delay:options:animations:completion:`, was added in iOS 7.

This method lets you provide a sequence of keyframe animations that are applied to one or more views during the duration of the animation.

If you simply change the center position of a single view to different locations, one right after the other, the system animates the view to move in a straight line between the points you specify.  (UIView keyframe animations can change properties aside from a view’s position, and can also animate multiple views at a time, but for now we’re discussing animations that move a single view.)

If you specify a cubic “calculation mode” using the options values UIViewKeyframeAnimationOptionCalculationModeCubic or UIViewKeyframeAnimationOptionCalculationModeCubicPaced, the view will instead follow a curved path between the points you specify. The documentation does not say what kind of cubic curve is used, but curve it follows appears to be very close to a Catmull-Rom spline. You should be aware that the path the view follows will sometimes “overshoot” the points you specify, like a baseball player who veers outside of the base-lines after he passes over a base, before moving back onto the base-line.

Core Animation’s CAKeyframeAnimation supports at least 2 distinct ways of specifying the path that an animation should follow.

One method provides an array of keyframe values and key times (plus other optional settings) that will let you animate your view’s layer through a series of points. Like UIView keyframe animation, you can use a variety of calculation modes including linear and cubic. Linear calculation causes the view’s layer to follow straight lines. Cubic calculation causes the view’s layer to follow a curved path.

The other method lets you specify a CGPath object, which can contain a complex path that can consist of a combination of straight lines, cubic or quadratic bezier curves, or arcs. This last method gives you the most control.

As an example, say we have an array of points randomPointsArray that contains a set of random points and we want our view to follow a curved path between those points.

To use UIView animation, the code might look like this:
    ```objective-c
	1.	int pointCount = prandomPointsArray.count;
	2. CGFloat relDuration = 1.0 / pointCount;
	3.	[UIView animateKeyframesWithDuration: totalDuration
	4.	                               delay: 0.0
	5.	                             options: UIViewKeyframeAnimationOptionCalculationModeCubicPaced + UIViewAnimationOptionCurveLinear
	6.	                          animations:
	7.	 ^{
	8.	   for (int index = 1; index <= pointCount; index++)
	9.	   {
	10.	     CGFloat startTime = ((CGFloat)index-1)/pointCount;
	11.	     
	12.	     [UIView addKeyframeWithRelativeStartTime: startTime
	13.	                             relativeDuration: relDuration
	14.	                                   animations: ^
	15.	      {
	16.	        int arrayIndex = index % pointCount;
	17.	        CGPoint thisPoint = randomPointsArray[arrayIndex];
	18.	
	19.	        //In our example, the array of points are in the coordinate space of theBlobView.
	20.	        //We need to convert them to the parent view’s coordinate space.
	21.	        thisPoint = [theBlobView convertPoint: thisPoint toView: theBlobView.superview];
	22.	        animationImageView.center = thisPoint;
	23.	      }
	24.	      ];
	25.	   }
	26.	   
	27.	 }
	28.	                          completion: nil
	29.	 ];
   '''

At line 3 we begin building the call to animateKeyframesWithDuration:delay:options:animations:completion:. 

In line 5, we specify options values of UIViewKeyframeAnimationOptionCalculationModeCubicPaced and UIViewAnimationOptionCurveLinear.

The UIViewKeyframeAnimationOptionCalculationModeCubicPaced option causes the animation to follow a curved, cubic path, and adjust the timing so that if the view moves different distances between the keyframes in the animation, the timing is adjusted so the object appears to travel at a constant speed.

The UIViewAnimationOptionCurveLinear option is the same value that is used in calls to animateWithDuration:delay:options:animations:completion:. It causes the animation to use a linear timing curve for the entire animation, as opposed to the default ease-in, ease-out timing. UIViewAnimationOptionCurveLinear is the equivalent of kCAMediaTimingFunctionLinear in the CAKeyframeAnimation code below.

If you did not specify this option, the animation would start slowly, quickly build to “full speed,” and then slow down near the end of the animation.

"Under the covers", iOS creates one or more CAAnimation objects that perform the animation(s) that you requested with your call to animateKeyframesWithDuration:delay:options:animations:completion:. Since a single UIView keyframe animation statement can animate any number of properties of any number of views, the system may generate multiple CAAnimation objects and run them on the layers of multiple views. (CAAnimation objects operate on CALayers, not views.)

Even if you create animations using UIView animation methods, you can then write code that acts on the resulting CAAnimation objects that are created by those UIView animation methods. A simple example of this is the code for the handleStopAnimation IBAction that gets called when you click the stop button. All it does is issues the command:

  [animationImageView.layer removeAllAnimations];

This works because our keyframe animation generates a CAKeyframeAnimation and adds it to the animationImageView's backing layer.




Animating an object through a series of points using a CAKeyframeAnimation:

It is also possible to move an object along a series of points using a subclass of CAAnimation. CAAnimation objects operate on layers, not views, however, so you animate the properties of a view’s layer instead of operating on the view.

You create a layer-based keyframe animation using an array of points  with a CAKeyframeAnimation. The code looks something like this:


	1. 	NSMutableArray *pointsArray = [NSMutableArray arrayWithCapacity: pointCount];
	2.	
	3. 	//For each point, create an NSValue of the coordinate, shifted to the coordinates
	4. 	//of the blobView's parent view.
	5.	 for (int index = 0; index <= pointCount; index++) //start and end with the first point
	6.	 {
	7.	   CGPoint aPoint = randomPoints[index % pointCount];
	8.	   aPoint = [theBlobView convertPoint: aPoint toView: theBlobView.superview];
	9.	   [pointsArray addObject: [NSValue valueWithCGPoint: aPoint]];
	10.	}
	11.	
	12.	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
	13.	pathAnimation.values = pointsArray;
	14.	pathAnimation.duration = totalDuration;
	15.	//Use linear timing.
	16.	pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	17.	
	18.	//Use cubic paced calculation, so we get a curved path and with constant velocity.
	19.	//(with paced animations we don't have to supply a keyTimes array)
	20.	pathAnimation.calculationMode = kCAAnimationCubicPaced;
	21.	pathAnimation.delegate = self;
	22.	
	23.	[animationImageView.layer addAnimation: pathAnimation forKey: @"path animation"];


In lines 1-10, we take the array of CGPoint values, shift them from their image’s coordinate system to the superview’s coordinate system, and ue them to build an array of NSValue objects (an NSValue is just an NSObject container for a scalar value like a CGPoint). Different types of CAKeyframeAnimation use different kinds of objects in the array of values.. If you are animating position, you use NSValues that contain points. If you’re animating transform.rotation, you would use an array of NSNumber objects containing angles. If you are animating colors, you would use an array of CGColor values, cast to id type.

In line 12, we create a CAKeyframeAnimation. Then in line 13, we install the array of values we created in lines 1-10.

In line 14, we set the duration for the entire animation.

In line 16, we select linear timing instead of the default ease-in, ease-out timing, where the animation starts slowly and accelerates to full speed, then slows to a stop at the end. This is the equivalent of UIViewAnimationOptionCurveLinear in the UIView keyframe animation code above.

In line 20, we select a calculation mode of cubic paced, using the constant kCAAnimationCubicPaced. This causes the animation to follow a cubic curve, and also causes the animation to move at a constant velocity. It is the equivalent of UIViewKeyframeAnimationOptionCalculationModeCubicPaced in a UIView keyframe animation.

In line 21, we set the view controller to be the delegate of the animation. This causes the animation to call the method animationDidStop:finished: when it completes. This is similar to the completion block in the animateKeyframesWithDuration:delay:options:animations:completion: method.

With the default settings, a CAKeyframeAnimation that animates a layer's position through a series of points using a cubic calculation mode follows a path that is very similar to a Catmull-Rom curve through those points. According to a post by an Apple developer on the Apple developer forums, CAKeyframeAnimations with cubic calculation actually use a more complex curve known as a Kochanek-Bartels spline. 

There are additional settings available for CAKeyframeAnimation objects that let you fine-tune the shape of the path that your layer will follow. Take a look at the continuityValues, biasValues, and tensionValues properties in the CAKeyframe class reference in Xcode for more information.
—

A third way to animate a layer along a curved path is to use a CAKeyframeAnimation and provide a CGPath for the animation to follow. (A CGPath is the Core Foundation equivalent of a UIBezierPath, and every UIBezierPath contains a CGPath). As of iOS 7.0.4, there is no method to animate a UIView along a UIBezierPath or CGPath.

The code to animate a layer along a CGPath is similar to the code to animate a layer through a series of keyframe points. You still create a CAKeyframeAnimation object, but instead of providing an array of key values, you provide a CGPath. The code looks like this:

	1.	  //Get the path.
	2.	  CGPathRef path = ((CAShapeLayer *)theBlobView.layer).path;
	3.	  CGPoint origin = theBlobView.frame.origin;
	4.	  CGAffineTransform transform = CGAffineTransformMakeTranslation( origin.x, origin.y);
	5.	 
	6.	  //The path is using zero-based coordinates.
	7.	  //Create a new path using the coordinates of the VC's content view
	8.	  path = CGPathCreateCopyByTransformingPath(path, &transform);
	9.	 
	10.	 //Create a keyframe animation object
	11.	 CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
	12.	 
	13.	 pathAnimation.duration = totalDuration;
	14.	 
	15.	 //Set it's timing function to linear, instead of the default ease-in, ease-out tiiming
	16.	 pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	17.	 
	18.	 //Select a paced calculation mode so the layer moves at a constant speed.
	19.	 
	20.	 pathAnimation.calculationMode = kCAAnimationPaced;
	21.	 
	22.	 //If the user selected it, make the layer rotate to follow the direction of the path.
	23.	 if (rotateImageSwitch.isOn)
	24.	   pathAnimation.rotationMode = kCAAnimationRotateAuto;
	25.	 
	26.	 //install the path in the animation.
	27.	 
	28.	 pathAnimation.path = path;
	29.	 
	30.	 //Set the view controller as the delegate of hte animation.
	31.	 pathAnimation.delegate = self;
	32.	 
	33.	 //Install the animation in the layer.
	34.	 [animationImageView.layer addAnimation: pathAnimation forKey: @"path animation"];

At line 20, we select a calculation mode of kCAAnimationPaced instead of kCAAnimationCubicPaced. (cubic calculation isn’t meaningful when providing a path.


CAKeyframeAnimation animation using a CGPath offers one option not available with other animation techniques: You can set the rotationMode on the animation to kCAAnimationRotateAuto, which causes the layer to rotate as it moves so that it always “faces forward” with respect to the path of the animation, like a train moving along a train track. (The layer rotates to follow the tangent of the path’s curve, where if the animation is moving on a horizontal line from left to right the layer is at a rotation of 0.) 

At lines 23 & 24, we set the rotationMode property of the animation object to kCAAnimationRotateAuto if the user selected that option.

All 3 animation methods are shown in a working code example available on github, at https://github.com/DuncanMC/RandomBlobs. The code for the second animation method, animating an object through a series of points using a CAKeyframeAnimation, is in a block of code which is disabled with an "if (FALSE)" statement.
