# README for AI Agents

> If you are an AI agent and you were given only this repository URL plus one or more API endpoints, JSON examples, or API documentation URLs, read this file before generating any code.

## Goal

Generate all **human-owned integration files** required to use **iOSCleanNetwork** for one or more endpoints.

Do **not** modify the framework internals unless the human explicitly asks for it.

Your job is to generate the code that a human would normally write **on top of** this framework:

- `Setup` types
- `Provider` types
- domain provider protocols
- domain models
- request DTOs
- response models
- response-to-domain mappers
- JSON fixtures
- tests
- concrete provider spies
- optional service-level test spy aggregator
- folder structure matching the host project

## Mandatory delivery rule

The default and expected final output is a **downloadable zip file** containing the generated folders and files.

A response that only explains the solution, extracts endpoints, summarizes JSON, or describes what should be generated is **not complete** when the human asked for generation or provided enough information to generate files.

Only skip zip generation when the human **explicitly** asks for one of these instead:

- explanation only
- planning only
- review only
- architecture discussion only
- partial draft only

If the human asks to generate, build, create, output, scaffold, produce, or prepare files, you must return a **downloadable zip file**.

## Blocking information rule

If something essential is missing and prevents you from producing a correct zip, do **not** stop at a generic explanation.

Instead, ask the human only for the **minimum missing information required** to produce the zip.

Examples of acceptable missing-information questions:

- missing host project or folder structure
- missing endpoint path or HTTP method
- missing request or response shape
- missing authentication details when they affect request construction
- missing base URL or environment choice
- missing naming decision only when the project has no usable convention and the choice materially affects output

Examples of unacceptable stopping points:

- “Here is how I would do it”
- “Here are the endpoints and JSONs”
- “Use this prompt in another tool”
- “I mapped the API but did not generate files”

When information is partially available, generate everything that is safely inferable and ask only for the exact missing blocking details.

## Framework repository

Framework URL: `https://github.com/alegelos/iOSCleanNetwork`

If the framework is already present **inside** the host project, do not add it again as a package dependency.
If the host project consumes it as an external package, then import and use it as a dependency.

## Required inputs

You may be given any combination of the following:

1. one or more API endpoints
2. example request JSONs
3. example response JSONs
4. OpenAPI / Swagger / Postman / HTML docs URL
5. a host project zip or repository
6. a list of features to implement

If API documentation is provided by URL, inspect it and infer the request and response models.
If example JSONs are provided, use them as the source of truth for transport models and test fixtures.
If the provided information is enough to generate files, do so immediately and return the zip.
If it is not enough, ask for the smallest missing set of inputs needed to still reach the zip.

## What you must generate

For each endpoint or API group, generate the files that the human should create in their project.

### Runtime

- `*Setup`
- `*Provider`
- Domain provider protocols
- Domain models
- request DTOs
- response models
- response-to-domain mapper extensions

### Testing

- JSON fixture files
- test files using `MockedURLSession`
- concrete provider spies written by hand
- optional service-level spy aggregator when it simplifies assertions

## Non-negotiable conventions

### 1. Folder structure

If the host project already exists, mirror its structure.
Do not invent a random layout if the project already has a clear convention.

If there is no host structure, generate this default layout:

```text
Feature/
├─ Domain/
│  ├─ Providers/
│  │  └─ ExampleFeatureProviderProtocol.swift
│  └─ Models/
│     └─ ExampleFeatureModel.swift
├─ Data/
│  └─ APIs/
│     └─ ExampleAPI/
│        ├─ Setup/
│        │  └─ ExampleAPISetup.swift
│        ├─ Provider/
│        │  └─ ExampleAPIProvider.swift
│        ├─ Responses/
│        │  └─ ExampleResponse.swift
│        └─ DTOs/
│           └─ ExampleDTO.swift
└─ Tests/
   └─ FeatureTests/
      └─ Data/
         └─ APIs/
            └─ ExampleAPI/
               ├─ Jsons/
               ├─ ExampleAPISetup+Json.swift
               ├─ ExampleAPIProviderTests.swift
               ├─ ExampleAPIProviderSpy.swift
               └─ FeatureServiceProviderSpy.swift
```

Rules:

- always generate both `Domain/` and `Data/`
- `Domain/Providers/` contains only protocols
- `Domain/Models/` contains only Domain model structs
- no DTOs in `Domain`
- no response models in `Domain`
- no concrete API implementation in `Domain`
- the concrete `Provider` lives in `Data`
- the concrete `Provider` must conform to the matching Domain protocol

### 2. `Setup` naming

Any type conforming to `ApiSetupProtocol` must end with `Setup`.

Examples:

- `GitHubUsersAPISetup`
- `StripePaymentsAPISetup`
- `SpotifyTracksAPISetup`

A `Setup` owns endpoint configuration only:

- path
- method
- headers
- body
- query items
- request construction

A `Setup` must conform to `ApiSetupProtocol`.

### 3. `Provider` naming

Any type that executes the request must end with `Provider`.

Examples:

- `GitHubUsersAPIProvider`
- `StripePaymentsAPIProvider`
- `SpotifyAPIProvider`

A `Provider` must:

- receive dependencies such as `baseURL`, `apiAccessProvider`, and `session`
- build the correct `Setup`
- perform the request
- decode the transport response
- map the decoded transport response into Domain models
- return the mapped Domain result
- conform to the feature protocol declared in `Domain/Providers/` when such protocol exists

### 4. Domain protocol naming

When generating the Domain protocol, place it in `Domain/Providers/` and make the name end with `Protocol`.

Rules:

- the protocol name must represent the **feature or capability**, not the raw API vendor name
- the protocol defines what the rest of the app or SDK consumes from the Data layer
- the protocol methods must return Domain models, never transport responses
- keep the protocol in `Domain`
- keep the concrete implementation in `Data`

Prefer names such as:

- `CardTokenProviderProtocol`
- `PaymentsProviderProtocol`
- `ProfileProviderProtocol`
- `SessionProviderProtocol`

Avoid transport-driven names such as:

- `CheckoutAPIProviderProtocol`
- `StripeAPIProviderProtocol`
- `SpotifyAPIProviding`

### 5. Transport model naming

Use these naming conventions:

- API responses: `*Response`
- request payload models / request parameters: `*DTO`

Examples:

- `CreatePaymentIntentDTO`
- `GitHubUserResponse`
- `SpotifyTrackResponse`

### 6. Domain model generation

Generate a `Domain/Models/` folder.

Rules:

- presenter-facing and feature-facing return types must be Domain models, not transport responses
- if multiple endpoints feed the same business entity, prefer one Domain model when it is semantically correct
- if an endpoint does not need a separate Domain model because the human explicitly wants the transport response directly, only do that when the human asks for it

### 7. Domain mapping in response models

For each API response model that maps into the Domain layer, add an extension in the `Data` layer.

Use this exact style:

```swift
extension ExampleResponse {
    // MARK: - Domain Mapper
    var domain: ExampleDomainModel {
        ExampleDomainModel(
            id: id,
            name: name
        )
    }
}
```

Rules:

- the mapper must live in the `Data` layer
- the computed property must be named `domain`
- the property must return the corresponding Domain model
- providers must call `.domain` before returning values through the Domain protocol
- arrays of responses must be mapped into arrays of Domain models before returning

### 8. Testing with JSON fixtures

Do **not** rewrite the production `Provider` for tests.
The same `Provider` used in production must also be used in tests.

Testing must work by:

- injecting `MockedURLSession`
- providing JSON fixture files
- keeping the same decoding logic as production
- keeping the same Domain mapping as production when the Provider returns Domain models

That means:

- no special test-only Provider implementation
- no duplicated request logic
- no manual fake decoding flow

Only the session changes.

### 9. `URLSessionSetupProtocol` for fixtures

If a `Setup` must be used with `MockedURLSession`, extend it to conform to `URLSessionSetupProtocol` and provide `jsonFileName`.

### 10. Spies

The framework provides the reusable protocol:

- `ProviderSpyProtocol`

The following are **not** generated by the framework and must be handwritten per project by the user or by you, the AI agent:

- concrete provider spies
- optional service-level spy aggregator
- tests using those spies

#### Provider-level spies

For each protocol that the human wants to observe, generate a handwritten spy wrapping the real implementation.

If a Domain protocol exists, the spy should normally wrap that Domain protocol.

Pattern:

- conform to `ProviderSpyProtocol`
- define `MethodKey`
- store `invocationsCount`
- store `failingMethos`
- wrap the real service
- in each method:
  - call `increment(...)`
  - call `try validateFailingMethods(method: ...)`
  - forward to the wrapped implementation

#### Service-level aggregator spy

When the feature involves multiple providers and tests would be noisy, generate a handwritten service-level spy aggregator.

That aggregator should:

- own multiple concrete provider spies
- expose `resetAllCounters()`
- expose `failingMethods(...)`
- expose `assertExpectedInvocations(...)`
- make tests short and readable

This aggregator is project-specific and must be handwritten too.

## Test style

Always write tests with:

- `Given`
- `When`
- `Then`

Keep tests short.

Prefer a style where the final assertions are concise, for example:

```swift
try service.assertExpectedInvocations(
    .user(.fetchProfile),
    .session((.renewToken, times: 2))
)
```

Prefer `expected` and `actual` naming when direct value assertions are needed.

## Multi-endpoint rule

If the human gives you multiple endpoints for the same API area, prefer a single `Setup` and a single `Provider` when that matches the project style.

Example:

- one `GET`
- one `POST`
- same API group
- same `Provider`
- same `Setup` enum with multiple cases

This is preferred over splitting everything into many tiny files unless the host project already does that.
