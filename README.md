RandomBlobs
===========

A project that shows how to create random, non-selfintersecting smoothly curved shapes using UIBezierPaths and Catmull-Rom spline based smoothing. (With a tip of the hat to Erica Sadun, who's path smoothing recipe is a key component.) 


This project demonstrates a number of iOS aninimation and drawing techniques, as well as a few others.

##Animation Techniques

* Using Catmull-Rom splines to create a path out of a set of points, where all the points are on a curve.
* Creating an animated shape using a `CAShapeLayer` and a `CABasicAnimation` that changes the layer's path
* Animating an object along a path [path animation] (link)
    * Doing keyframe animation animation using the new iOS 7 UIView method `animateKeyframesWithDuration:delay:options:animations:completion:`
    * Duplicating the results of `animateKeyframesWithDuration:delay:options:animations:completion:` using Core Animation CAKeyframeAnimation and an array of points
    * Creating keyframe animations using a `CAKeyframeAnimation` and a `CGPath`


##Miscellaneous techniques

* Using block-based NSNotificationCenter observers
* Sliding your views to make room for the keyboard



[path animation]:(/path_animation.md)