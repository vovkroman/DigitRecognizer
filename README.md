# DigitRecognizer

### Description

Demo app that efficiently solves **the handwritten digit recognition problem** (see demo), using Convolutional Neural Network ([CNN](https://en.wikipedia.org/wiki/Convolutional_neural_network)), structure proposed by [Yann LeCun](https://en.wikipedia.org/wiki/Yann_LeCun), aka [LeNet](https://en.wikipedia.org/wiki/LeNet).
![](Sources/drawer_player.gif).

### Requirements (Programming language)

Swift 5.2 & Objective-C 2.0

### Structure of project

The project contains 4 separated modules/frameworks (descriptions of each of them are listed below):

- [x] **FutureKit** - framework which provides an API for performing nonblocking asynchronous requests and combinator interfaces for serializing the processing of requests, error recovery and filtering. In most iOS libraries asynchronous interfaces are supported through the delegate-protocol pattern or with a callback. Even simple implementations of these interfaces can lead to business logic distributed over many files or deeply nested callbacks that can be hard to follow. **FutureKit** provides a very simple API to get rid of callback hell (inspired by [www.swiftbysundell.com](https://www.swiftbysundell.com/articles/under-the-hood-of-futures-and-promises-in-swift/)).
- [x] **Canvas** - framework provides [UIKit UIView](https://developer.apple.com/documentation/uikit/uiview), that supports self-drawing in the most performant way.
- [x] **MNIST** -
- [x] **Digit Recognizer** - iOS target which aggregates all frameworks listed above.
