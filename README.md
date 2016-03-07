### Tailor

Tailor is a fast, safe, simple web development framework built for the Swift
programming language.

### How to Use Tailor

Here's what you need to do to start your first Tailor app:

1. Create a `Package.swift` file with Tailor as a dependency:

        let package = Package(
          dependencies: [
            .Package(url: "https://github.com/brownleej/tailor", Version(3,0,0, prereleaseIdentifiers: ["alpha"])),
          ]
        )

2. Create a `main.swift` file that starts Tailor:

        import Tailor
        Application.start()

3. Run the application:

        $ .build/debug/MyApp server

That will start a dummy server with no content. You can learn more about
building Tailor apps at
[the official website](https://tailorframe.work/). That site also has
[documentation](https://tailorframe.work/docs/overview/) and
[tutorials](https://tailorframe.work/tutorials/).

### Supported Platforms

Right now, Tailor only runs on Linux. Supporting Mac builds is a major goal, but
in the mean time you can build Tailor in a [docker](https://docker.io) container
running Linux. We have a [repository](https://github.com/brownleej/swift-docker)
that contains scripts for setting up a local Swift development environment as
well as an AWS server environment.

### Building Tailor from Source

You can build Tailor from source by running `swift build` from the root of the
repository. You can run the tests by running `.build/debug/TailorTests`.

### Feedback and Contributions

You can give feedback by [reaching out to me](http://johnbrownlee.com/contact),
opening issues in Github, or making pull requests.
