# CollectionConcurrencyKit

Welcome to **CollectionConcurrencyKit**, a lightweight Swift package that adds asynchronous and concurrent versions of the standard `map`, `flatMap`, `compactMap`, and `forEach` APIs to all Swift collections that conform to the `Sequence` protocol. That includes built-in types, like `Array`, `Set` and, `Dictionary`, as well as any custom collections that conform to that protocol.

CollectionConcurrencyKit can be used to implement high-performance data processing and algorithms in a way that fully utilizes Swift’s built-in concurrency system. It’s heavily unit tested, fully documented, and used in production to generate [swiftbysundell.com](https://swiftbysundell.com).

## Asynchronous iterations

The async variants of CollectionConcurrencyKit’s APIs enable you to call `async`-marked functions within your various mapping and `forEach` iterations, while still maintaining a completely predictable, sequential execution order.

For example, here’s how we could use `asyncMap` to download a series of HTML strings from a collection of URLs:

```swift
let urls = [
    URL(string: "https://apple.com")!,
    URL(string: "https://swift.org")!,
    URL(string: "https://swiftbysundell.com")!
]

let htmlStrings = try await urls.asyncMap { url -> String in
    let (data, _) = try await URLSession.shared.data(from: url)
    return String(decoding: data, as: UTF8.self)
}
```

And here’s how we could use `asyncCompactMap` to ignore any download that failed, by returning an optional value, rather than throwing an error:

```swift
let htmlStrings = await urls.asyncCompactMap { url -> String? in
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return String(decoding: data, as: UTF8.self)
    } catch {
        return nil
    }
}
```

Each of CollectionConcurrencyKit’s APIs come in both throwing and non-throwing variants, so since the above call to `asyncCompactMap` doesn’t throw, we don’t need to use `try` when calling it.

## Concurrency

CollectionConcurrencyKit also includes concurrent variants of `forEach`, `map`, `flatMap`, and `compactMap`, which perform their iterations in parallel, while still maintaining a predictable order when producing their results.

For example, since our above HTML downloading code consists of completely separate operations, we could instead use `concurrentMap` to perform each of those operations in parallel for a significant speed boost:

```swift
let htmlStrings = try await urls.concurrentMap { url -> String in
    let (data, _) = try await URLSession.shared.data(from: url)
    return String(decoding: data, as: UTF8.self)
}
```

And if we instead wanted to parallelize our `asyncCompactMap`-based variant of the above code, then we could do so by using `concurrentCompactMap`:

```swift
let htmlStrings = await urls.concurrentCompactMap { url -> String? in
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return String(decoding: data, as: UTF8.self)
    } catch {
        return nil
    }
}
```

Regardless of whether we choose the async or concurrent versions of CollectionConcurrencyKit’s APIs, the order of the returned results is always guaranteed to be the exact same as when calling the standard library’s non-async versions of those APIs. So, the order of the `htmlStrings` array will be identical across all of the above four code samples (ignoring any `nil` values produced by the compactMap-variants).

## What APIs are included?

CollectionConcurrencyKit adds the following APIs to all `Sequence`-conforming Swift collections:

- Async variants that perform each of their operations in sequence, one after the other:
    - `asyncForEach`
    - `asyncMap`
    - `asyncCompactMap`
    - `asyncFlatMap`
- Concurrent variants that perform each of their operations in parallel (while still maintaining a predictable output order):
    - `concurrentForEach`
    - `concurrentMap`
    - `concurrentCompactMap`
    - `concurrentFlatMap`

Both throwing and non-throwing versions of all of the above APIs are included. To learn more about `map`, `flatMap`, and `compactMap` in general, check out [this article](https://swiftbysundell.com/basics/map-flatmap-and-compactmap).

## System requirements

CollectionConcurrencyKit works on all operating system versions that support Swift’s concurrency system, which includes iOS 13+, macOS 10.15+, watchOS 6+, and tvOS 13+, as well as Linux (when using a Swift toolchain of version 5.5 or higher). Note that you need to use Xcode 13.2 or later when using CollectionConcurrencyKit on Apple’s platforms.

## Installation

CollectionConcurrencyKit is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it within another Swift package, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit.git", from: "0.1.0")
    ],
    ...
)
```

If you’d like to use CollectionConcurrencyKit within an iOS, macOS, watchOS or tvOS app, then use Xcode’s `File > Add Packages...` menu command to add it to your project.

Then import CollectionConcurrencyKit wherever you’d like to use it:

```swift
import CollectionConcurrencyKit
```

For more information on how to use the Swift Package Manager, check out [this article](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager), or [its official documentation](https://swift.org/package-manager).

## Support and contributions

CollectionConcurrencyKit has been made freely available to the entire Swift community under the very permissive [MIT license](LICENSE.md), but please note that it doesn’t come with any official support channels, such as GitHub issues, or Twitter/email-based support. So, before you start using CollectionConcurrencyKit within one of your projects, it’s highly recommended that you spend some time familiarizing yourself [with its implementation](https://github.com/JohnSundell/CollectionConcurrencyKit/blob/main/Sources/CollectionConcurrencyKit.swift), in case you’ll run into any issues that you’ll need to debug.

If you’ve found a bug, documentation typo, or if you want to propose a performance improvement, then feel free to [open a Pull Request](https://github.com/JohnSundell/CollectionConcurrencyKit/compare) (even if it just contains a unit test that reproduces a given issue). While all sorts of fixes and tweaks are more than welcome, CollectionConcurrencyKit is meant to be a very small, focused library, so it’s considered more or less feature-complete. So, if you’d like to add any significant new features to the library, then it’s recommended that you fork it, which will let you extend and customize it to fit your needs.

Hope you’ll enjoy using CollectionConcurrencyKit!
