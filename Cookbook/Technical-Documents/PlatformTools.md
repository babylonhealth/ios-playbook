iOS Platform Tools
==================

## Overview

This article covers some existing useful dev-tools specifically for iOS Platform Team to improve dependency analysis, build-time measurement, and so on.

See Also:
- [\[IOSP\-65\] Create the dependency graph](https://babylonpartners.atlassian.net/browse/IOSP-65)
- [\[IOSP\-65\] Dependency Graph \- iOS 🚀 \- Google Drive](https://drive.google.com/drive/u/1/folders/1XD3emGwNdtbIG60MduGOH9GlepEEsG0w)

---

## Table of Contents

### Dependency Graph Visualiser

- [PaulTaykalo/objc-dependency-visualizer](https://github.com/PaulTaykalo/objc-dependency-visualizer)
- [matsoftware/swift-code-metrics](https://github.com/matsoftware/swift-code-metrics)

### Build Time Measurement

- [PaulTaykalo/xcode-build-times-rendering](https://github.com/PaulTaykalo/xcode-build-times-rendering)
- [spotify/XCLogParser](https://github.com/spotify/XCLogParser)

### Others

- [uber/uber-poet](https://github.com/uber/uber-poet)

---

## Dependency Graph Visualiser

### 🛠 [PaulTaykalo/objc-dependency-visualizer](https://github.com/PaulTaykalo/objc-dependency-visualizer)

Guide: [Home · PaulTaykalo/objc\-dependency\-visualizer Wiki](https://github.com/PaulTaykalo/objc-dependency-visualizer/wiki)

`objc-dependency-visualizer` is written in Ruby which searches for Xcode-generated `.swiftdeps` files in `DerivedData` to collect all dependencies to create a beautiful graph visualisation using `d3.js` .

Each node corresponds to either type or global variable / function.

DOT format with graphviz rendering is also supported.

#### Output

<img src="Assets/platform-tooling/visualizer-Octopus-ExchangeableTabBar.png">
<img src="Assets/platform-tooling/visualizer-BabylonDependencies.png">
<img src="Assets/platform-tooling/visualizer-BabylonCore-graphviz.png">

#### Script

```sh
TARGET='BabylonCore'

# Update origin.js (dependency graph dataset)
# -s PROJECT_NAME -f FORMAT --path path-to-swiftdeps-dir
./generate-objc-dependencies-to-json.rb \
    --swift-dependencies \
    -f json-var \
    -s "Babylon" \
    --target "$(TARGET)" \
    > origin.js
open index.html
```

```sh
# Generate PNG image from DOT file.
./generate-objc-dependencies-to-json.rb \
    --swift-dependencies \
    -f dot \
    -s "Babylon" \
    --target "$(TARGET)" \
    > output/dot/$(TARGET).dot
dot -Tpng output/dot/$(TARGET).dot -o output/dot/$(TARGET).png
```

### 🛠 [matsoftware/swift-code-metrics](https://github.com/matsoftware/swift-code-metrics)

Guide: [swift\-code\-metrics/GUIDE\.md](https://github.com/matsoftware/swift-code-metrics/blob/master/docs/GUIDE.md)

`swift-code-metrics` is a code metrics analyzer written in Python that parses Swift source code to generate "1 framework per node" dependency graph as well as other metrics such as code distribution, component stability, number of classes / imports / commetns / LoC, etc.

#### Output

##### Internal graph

<img src="Assets/platform-tooling/metrics-internal_dependencies_graph.png">

##### Internal & External graph

<img src="Assets/platform-tooling/metrics-dependencies_graph.png">

##### Code Distribution

<img src="Assets/platform-tooling/metrics-code_distribution.png" style="max-height: 300px">

<img src="Assets/platform-tooling/metrics-deviation_from_the_main_sequence.png" style="max-height: 300px">


#### Script

```sh
# pip3 install swift-code-metrics
# swift-code-metrics --source ./ --artifacts output --generate-graphs

git clone https://github.com/matsoftware/swift-code-metrics

# NOTE: Latest code works better.
python3 swift-code-metrics-runner.py \
    --source ./path/to/babylon-ios/ \
    --artifacts output \
    --generate-graphs
```

---

## Build Time Measurement

### 🛠 [PaulTaykalo/xcode-build-times-rendering](https://github.com/PaulTaykalo/xcode-build-times-rendering)

`xcode-build-times-rendering` creates a build-time gantt chart by injecting timestap logging in Run Script Build Phase.
This will also support 3rd party libraries using CocoaPods.

#### Output

<img src="Assets/platform-tooling/buildtime-internal.png">
<img src="Assets/platform-tooling/buildtime-all.png">

(NOTE: Some texts are manually added for more visibility)

#### Script

```sh
# NOTE: clean DerivedData first

# Setup Xcode script build phases.
./bin/xcode-build-times \
    --events-file output.txt \
    install ./path/to/babylon-ios

# Generate gantt chart.
./bin/xcode-build-times generate --events-file output.txt

open xcode-build-times-chart/gantt.html
```

### 🛠 [spotify/XCLogParser](https://github.com/spotify/XCLogParser)

`spotify/XCLogParser` is a log parser for Xcode-generated `xcactivitylog` to unzip its gunzip-ed file and measure build-time, warnings and errors, slowest file compilation, etc.

#### Output

<img src="Assets/platform-tooling/xclogparser-overview.png">
<img src="Assets/platform-tooling/xclogparser-slowest.png">

#### Script

```sh
git clone https://github.com/spotify/XCLogParser
rake build[release]

# Parses `xcactivitylog` and report in html/json format.
xclogparser parse --project Babylon --reporter html

# Dumps the whole content of an xcactivitylog file as JSON.
xclogparser dump --project Babylon --output activity.json --redacted

# Outputs the contents of LogStoreManifest.plist.
xclogparser manifest --project Babylon
```

---

## Others

### 🛠  [uber/uber-poet](https://github.com/uber/uber-poet)

[Introducing Uber Poet, an Open Source Mock App Generator for Determining Faster Swift Builds \| Uber Engineering Blog](https://eng.uber.com/uber-poet/)

Doc: [uber\-poet/layer\_types\.md](https://github.com/uber/uber-poet/blob/master/docs/layer_types.md)

`uber-poet` is a mock-app generator with tons of frameworks being linked in many different dependency graph styles that builds on top of [facebook/buck](https://github.com/facebook/buck) build system.

While this tool is not for measuring real-app dependency graph, it is useful to measure the build-time difference depending on the graph configuration before actually starting modularisation refactoring.

According to the above blog post, there was no significant difference among each graph.
