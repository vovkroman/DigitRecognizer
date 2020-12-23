# DigitRecognizer

### Description

This companion app that efficiently solves **the handwritten digit recognition problem** (see demo), using Convolutional Neural Network ([CNN](https://en.wikipedia.org/wiki/Convolutional_neural_network)), structure proposed by [Yann LeCun](https://en.wikipedia.org/wiki/Yann_LeCun), aka [LeNet](https://en.wikipedia.org/wiki/LeNet).

![](Sources/drawer_player.gif).

### Requirements (Programming language)

Swift 4.2 and more & Objective-C 2.0

### Structure of project

The project contains 4 separated modules/frameworks (descriptions of each of them are listed below):

- [x] **FutureKit** - framework which provides an API for performing nonblocking asynchronous requests and combinator interfaces for serializing the processing of requests, error recovery and filtering. In most iOS libraries asynchronous interfaces are supported through the delegate-protocol pattern or with a callback. Even simple implementations of these interfaces can lead to business logic distributed over many files or deeply nested callbacks that can be hard to follow. **FutureKit** provides a very simple API to get rid of callback hell (inspired by [www.swiftbysundell.com](https://www.swiftbysundell.com/articles/under-the-hood-of-futures-and-promises-in-swift/)).

- [x] **Canvas** - framework provides [UIKit UIView](https://developer.apple.com/documentation/uikit/uiview), that supports drawing action in the most performant way. There are 2 approaches to solve current problem: 
1. [**Core Graphics**](https://developer.apple.com/documentation/coregraphics) which performs drawing on CPU (using UIGraphicsGetCurrentContext); 
2. **Core Animation**[https://developer.apple.com/documentation/quartzcore], works with [CALayer](https://developer.apple.com/documentation/quartzcore/calayer), which performs drawing specificaly on GPU.

In the current implementation, the second approach was applied. Mechanism of drawing on Canvas is pretty staright forward:
1. In **touchesMoved**, we store the touch points inside of an array;
2. We call **setNeedsDisplay(rect:)** to mark the dirty area for redraw;
3. In **draw(layer:ctx:)**, we loop over the array of points and perform the actual drawing;
4. When the array reaches 200 points, we flatten the image and empty the array;

Follow the [link](https://github.com/vovkroman/DigitRecognizer/tree/develop/Canvas/Canvas) to get acquainted.
- [x] **MNIST** - framework implementing the logic of digit recognition, by given image. 
It has been implemented using Apple's [**BNNS**](https://developer.apple.com/documentation/accelerate/bnns). **BNNS** library is a collection of functions that you use to construct neural networks for training and inference. It’s supported in macOS, iOS, tvOS, and watchOS. BNNS provides routines optimized for high performance and low-energy consumption across all CPUs supported on those platforms.



- [x] **Digit Recognizer** - iOS target which aggregates all frameworks listed above.
