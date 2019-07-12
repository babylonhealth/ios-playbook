# How to implement a feature that works with the backend
Let's look at a minimal and simple example of working with the backend to get some items into our view model, before moving on to more difficult topics.

## A simple example
Imagine some endpoint on the backend returns this piece of JSON:
``` json
{
  "cities": [
    {
      "name": "London"
    },
    {
      "name": "Bath"
    }
  ]
}
```

First, we want to define some data types, to which we will map this JSON. This is known as a *response*.

### Response
A `Response` is a data type which wraps the whole response returned from a network call. In many cases it is unnecessary and you can extract the values from a single key directly, just like in this example, where there is only one key. For the sake of this exercise, let's stick with it though.

A response data type is a plain struct conforming to `Equatable`  (this is usually necessary for tests) and `Decodable`. We also define an additional data type for the city itself. You will want to define all the new data types necessary to describe a response:
``` swift
struct CitiesResponse: Equatable, Decodable {
    let cities: [City]
}

struct City: Equatable, Decodable {
    let name: String
}
```

Note that we put `Decodable` directly on the structs in this simple case, but in general you'll want to put it in an extension because some customisation is needed when decoding the objects.

As a rule, all the structs are defined at the top level rather than as subtypes (i.e. `CitiesResponse.City`). Most of the structs are used throughout the app, all the way up to the renderers, and it would be inconvenient to always use a fully-qualified name or set up type aliases.

When the response data type is ready, the next thing you'll want to create is a *service*. But before that, a few words about a *backend resource*.

### Backend resource
`BackendResource` is an abstraction over a network request, allowing to provide all the necessary context to actually perform it.

Essentially, it is defined like this:
``` swift
struct BackendResource<Request, Response, Auth> {
    let path: ResourcePath         // URL
    let method: Resource.Method    // GET, POST…
    …
    var headers: [String: String]
}
```

As you can see, it contains everything that the network layer may need to make a network request: 
* a request type that we provide if it's a `POST` endpoint
* the type of the response we expect (that we just defined above)
* the auth provider (more on that later)
* the URL
* request method
* any additional headers we want to add

A *service* that we are about to define is responsible for generating a `BackendResource` for each request that we want to make.

### Service
The purpose of a `Service` is to provide a `BackendResource` to execute network requests. As you may have guessed, this is also a simple struct, used as a namespace.

As a rule, `GET` requests are named starting with `fetch`:
``` swift
struct CitiesService {
    static func fetchCitiesResource() -> BackendResource<Void, CitiesResponse, KongAuth> {
        let citiesPath = "/v1/cities"
        return BackendResource(
            path: .api(.core, citiesPath),
            method: .GET
        )
    }
}
```

That's it!

The `Service` usually provides `static` functions with parameters needed to create a request. In this case, we use `Void` in place of `Request` because it's just a `GET`, but we specify `CitiesResponse` as that's what we expect from the backend. 

The URL is defined as a path, which is then constructed into a full URL with a helper enum. This accommodates the use of different environments while not requiring any changes from the clients.

`KongAuth` is the concrete type of auth this endpoint expects as there is also `ClinicalAuth`, used for different backend endpoints.

Now that we have our `BackendResource`, we can define a *business controller* which will tie everything together and make the network call.

However, first we need to learn about accessing backend resources.

### Accessible
`Accessible` is a protocol with just one function, which takes a backend resource and returns a signal producer with the parsed result:
``` swift
func access<Request, Response>(_ resource: BackendResource<Request, Response, NoAuth>, with request: Request) -> SignalProducer<Response, CoreError>
```

`CoreError` is preferred as it allows both network and parsing errors and is used throughout the network layer.

You may have noticed `NoAuth` in the signature – this is only good for unauthenticated requests, like fetching data before the user logs in. After that, you'll likely want to use `AuthenticatedAccessible` which provides a slightly different method:

``` swift
func access<Request, Response>(_ resource: BackendResource<Request, Response, KongAuth>, with request: Request) -> SignalProducer<Response, CoreError>
```

Using either `Accessible` or `AuthenticatedAccessible`, you can perform the network request defined by a backend resource, and this is exactly what we do in the business controller.

### Business controller
A `BusinessController` is the entity you will be interacting with in the view model, and as such, it needs to be injected in order to be stubbed for testing the view model, which means it is defined first as a protocol:

``` swift
protocol CitiesBusinessControllerProtocol {
    func fetch() -> SignalProducer<CitiesResponse, CoreError>
}
```

Again, the business controller uses `fetch` terminology for getting some data from the backend. As this is the default and only method which gets no parameters, we call it simply `fetch()` without any modifiers.

It returns a signal with the parsed response, which we can use in our view model directly.

Let's define the concrete class for this protocol:
``` swift
struct CitiesBusinessController: CitiesBusinessControllerProtocol {
    private let accessible: AuthenticatedAccessible

    init(accessible: AuthenticatedAccessible) {
        self.accessible = accessible
    }

    func fetch() -> SignalProducer<CitiesResponse, CoreError> {
        let resource = CitiesService.fetchCitiesResource()
        return accessible.access(resource)
    }
}
```

As simple as that: we get a backend resource from `CitiesService` , access it with the provided `AuthenticatedAccessible` and return the result.

Note that we didn't specify the second parameter (request) for `accessible.access(…)`. Earlier we defined the request type as `Void`, which allows us to use a single-parameter convenience method on `AuthenticatedAccessible`, it simply calls `access(resource, with: ())`.

Let's see how we may use the business controller in a view model.

### View model
In the view model, we usually keep the results of a fetch in the `State`:
``` swift
struct State {
    var cities: [City]
}
```

The entities we're loading are usually supplied through an `Event`:
``` swift
enum Event {
    case didLoad(CitiesResponse)
}
```

When the view model gets an event, `reduce` is called and we can set the new value:
``` swift
static func reduce(state: State, event: Event) -> State {
    switch event {
    case let .didLoad(citiesResponse):
        return state.with(set(\.cities, citiesResponse.cities))
    }
}
```

Now `state.cities` contains the values we fetched and parsed from the network!

In order to trigger loading, we define a `Feedback` and transform a network response in order to conform to the signature of the effect:
``` swift
private static func whenLoading(
    citiesBusinessController: CitiesBusinessControllerProtocol
) -> Feedback<State, Event> {
    return Feedback(predicate: ^\.isLoading) { _ -> SignalProducer<Event, NoError> in
        citiesBusinessController.fetch()   // SignalProducer<CitiesResponse, CoreError>
            .map(Event.didLoad)            // SignalProducer<Event, CoreError>
            .replaceError(Event.didFail)   // SignalProducer<Event, NoError>
    }
}
```

Note that `citiesBusinessController` is provided as a parameter to the feedback function and doesn't require `self`.

There is one last piece of the puzzle missing: how does the view model get the concrete class of the business controller? This involves something called a *builder*, which is responsible for constructing objects and providing the dependencies they need.

### Builder
A builder, usually defined as a `struct`, is used to construct what essentially are screens (i.e. view controllers) at runtime, which is why it's using concrete classes. During testing, view models, business controllers and renderers are tested separately, so there is no need for a builder to bring it all together.

The relevant part of a builder, where we provide our new business controller to the view model, may be implemented like this:
``` swift
protocol CitiesBuildingMaterials {
    let session: AuthenticatedAccessible
}

struct CitiesBuilder {
    func make(with buildingMaterials: CitiesBuildingMaterials) -> UIViewController {
        let session = buildingMaterials.session

        let viewModel = CitiesViewModel(
            citiesBusinessController: CitiesBusinessController(accessible: session)
        )

        …
    }
}
```

Note that the approach to builders will be changed with the “[Builders to functions](../Proposals/BuildersToFunctions.md)” proposal, and they will become free functions.

### Feature structure
The business controller, service and related data types should all be grouped in an `API` directory if they are all for the same single feature:
```
Features
└── Cities
    ├── Tests
    │   ├── Fixture/
    │   ├── Canned Responses/
    │   ├── CitiesBusinessControllerTests.swift
    │   ├── CitiesServiceTests.swift
    │   ├── CitiesDecodingTests.swift
    │   ├── CitiesExpectations.swift
    │   ├── CitiesViewModelTests.swift
    │   ├── CitiesRendererSnapshotTests.swift
    ├── API
    │   ├── CitiesBusinessController.swift
    │   ├── CitiesService.swift
    │   ├── CitiesResponse.swift
    │   └── City.swift
    ├── CitiesViewModel.swift
    ├── CitiesRenderer.swift
    ├── CitiesFlowController.swift
    └── CitiesBuilder.swift
```

## Advanced topics
With the simple case covered, let's move on to more difficult topics.

Most of those are revolving around customising decoding and encoding at the `Service` level with `BackendResource`, so at first let's describe what a *parser* is.

### Parser

`Parser` is a namespace for a set of functions which encode and decode objects with `JSONSerialization` and generally return either a `SignalProducer` or a `Result`. There is much more going under the hood, so it's worth to study the source code.

We are mostly interested in two fuctions, the first is `parse` to decode the response:
``` swift
static func parse<T>(_ data: Data) -> Result<T, CoreError> where T: Decodable
```

Other overloads can also take a custom `JSONDecoder`, a JSON key and specify whether to fail parsing or skip malformed elements. We'll look at these options shortly.

The second function is `encode` to produce the request:
``` swift
static func encode<T>(_ item: T) -> Result<Data, CoreError> where T: Encodable
```

`encode` can also take a custom `JSONEncoder`.

`BackendResource` uses `Parser` to decode and encode responses and requests, and we can use it ourselves to customise how that is happening by overriding response and request handlers on `BackendResource`.

`BackendResource` takes two additional parameters, `request` and `response`, which have the following signatures:
``` swift
typealias RequestHandler = (Request, JSONEncoder) -> Result<Data, CoreError>
typealias ResponseHandler = (Data, URLResponse) -> Result<Response, CoreError>
```

Essentially, if we specify a simple encodable `Request`, internally this happens:
``` swift
extension BackendResource where Request: Encodable, Response: Decodable {
    public init(…) {       // We don't specify request or response here.
        self.init(         // But in this init they are required.
            …
            request: Parser.encode,
            response: { data, _ in Parser.parse(data) }
        )
    }
}
```

Let's see some examples of how we might customise this behaviour in various situations.

### Don't create a Response type for single-key JSON

Given the JSON from our simple example, we might as well not create `CitiesResponse` just to wrap the request, and use the `key` parameter on the parser to “key” into the data (get it?).

In our `CitiesService`, the call would be:
``` swift
static func fetchCitiesResource() -> BackendResource<Void, [City], KongAuth> {
    return BackendResource(
        path: .api(.core, citiesPath),
        method: .GET,
        response: { data, _ in Parser.parse(data, key: "cities", strategy: .prune) }
    )
}
```

What this does is decodes the array of cities directly from JSON, without the need for intermediate data structures. This works well for simple responses.

Note that our `BackendResource` signature now has `[Cities]` in it instead of `CitiesResponse`.

One other new thing here is the `strategy` parameter in the `Parser` call. The parameter is an enum applying specifically to arrays, and it has two cases:
1. `prune` (which we used in the call) skips any value in the array which could not be decoded. If one or more of the cities fails to be decoded, in the worst case we would get an empty array.
2. `strict` fails the whole parsing if one of the child values could not be parsed i.e. you would get an error.

Another way to approach this situation would be to define a custom `Decodable` extension for `CitiesResponse` which would filter out malformed cities, but more on this later.

### Supply a custom JSON decoder to BackendResource

When field names or dates are involved, we can pass our own `JSONDecoder` to the `BackendResource` initialiser instead of working in the `ResponseHandler` closure.

This is especially useful if e.g. on the backend your city has a field `city_name` but in your `City` struct it's defined as `cityName`. This case is handled by an option on a JSON decoder:
``` swift
struct CitiesService {
    // `internal` access level to allow for testing.
    internal static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static func fetchCitiesResource() -> BackendResource<Void, CitiesResponse, KongAuth> {
        let citiesPath = "/v1/cities"
        return BackendResource(
            path: .api(.core, citiesPath),
            method: .GET,
            decoder: jsonDecoder
        )
    }
}
```

We simply pass our `JSONDecoder` as a parameter when creating the `BackendResource`, which is executed internally as:
``` swift
extension BackendResource {
    public init(
        …
        decoder: JSONDecoder
    ) {
        self.init(
            …
            response: { data, _ in Parser.parse(data, decoder: decoder) }
        )
    }
}
```








### Control value mapping with a `Decodable` extension
    cards = try values.decodeArraySafely([HomeHubCard].self, forKey: .cards)
    throw decoder.dataCorrupted("Can't decode CreateAppointmentError")
    NotEmptyDecodable
### Use a custom request encoder
``` swift
static func obtainQuestions(socialSecurityNumberSuffix: String) -> BackendResource<Void, IDologyResponseDTO, KongAuth> {
        return BackendResource(
            path: .api(.ai, "/identity-verification/v1/session/"),
            method: .POST,
            request: { _, encoder in
                Parser.encode(
                    ["ssnLast4": socialSecurityNumberSuffix],
                    encoder: encoder
)
}
)
    }
    
        static var post: BackendResource<AddressDTO, RegisteredAddressDTO, KongAuth> {
        return BackendResource(path: .api(.core, "/api/v1/patients/\(KongAuth.patientId)/addresses"), method: .POST, request: { address, _ in
            return Parser.encode(["address": address])
        })
    }
```
### Supply a custom `JSONDecoder` to `BackendResource`
internal static var jsonDecoder
encoder.dateEncodingStrategy = .formatted(DateFormatHelpers.justDateFormatter)
### Supply a custom `JSONEncoder`
encoder.keyEncodingStrategy = .convertToSnakeCase

different ways to achieve the same thing
### Using a `Request` type to access a `BackendResource`
### Using a custom response error
AddressBusinessController
case .network(.server(422, _)):
