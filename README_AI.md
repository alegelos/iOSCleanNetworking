# README for AI Agents

> If you are an AI agent and you were given this repository together with endpoints, JSON examples, docs, or a PDF, read this file before generating any code.

## Goal

Generate the human-owned integration files required to use `iOSCleanNetwork` for one or more services.

Do not modify the framework internals unless the human explicitly asks for it.

Your final output must be delivered as a **zip file**.

Manual files are optional. By default, focus on the auto-generated integration files only.

## Framework repository

Framework URL: `https://github.com/alegelos/iOSCleanNetwork`

If the framework already exists inside the host project, do not add it again as a dependency.

If the host project consumes it as an external package, integrate against it without rewriting its internals unless explicitly requested.

## Expected inputs

You may receive any combination of:

1. endpoint descriptions
2. request JSON examples
3. response JSON examples
4. OpenAPI, Swagger, Postman, HTML docs, or a PDF
5. a host project zip or repository
6. a list of features to implement

When documentation is provided by URL or PDF, inspect it and infer:

- endpoints
- headers
- methods
- request body structure
- response structure
- required domain mapping

If example JSON is provided, use it as the source of truth for transport models and fixtures.

## What you must generate

For each service or endpoint group, generate the files a human would normally add on top of the framework.

### Runtime

- domain provider protocols
- domain models
- `*Setup`
- `*Provider`
- DTOs
- response models
- domain mapper extensions

### Testing

- JSON fixtures
- tests using `MockedURLSession`
- optional concrete spies when useful

## Non-negotiable output structure

### 1. Root folder

The generated output must start with a root folder named after the project, feature, or module.

Example:

```text
ProjectName/
├─ Domain/
└─ Data/
```

### 2. Domain folder

`Domain` must contain exactly these folders:

```text
Domain/
├─ Providers/
└─ Models/
```

Rules:

- `Domain/Providers/` contains only the protocols of the features
- `Domain/Models/` contains only domain model structs
- no DTOs in `Domain`
- no response models in `Domain`
- no concrete provider implementations in `Domain`

Example:

```text
Domain/
├─ Providers/
│  ├─ CardTokenProviderProtocol.swift
│  └─ PaymentsProviderProtocol.swift
└─ Models/
   ├─ CardToken.swift
   └─ PaymentSession.swift
```

### 3. Data folder

`Data` must contain an `APIs` folder:

```text
Data/
└─ APIs/
```

Inside `Data/APIs/`, create one folder per service or endpoint group.

Example:

```text
Data/
└─ APIs/
   ├─ TokensAPI/
   └─ PaymentsAPI/
```

Inside each service folder, generate this exact pattern:

```text
<ServiceName>/
├─ <ServiceName>Setup/
├─ <ServiceName>Provider/
├─ Responses/    // only if there are response structs
└─ DTOs/         // only if there are DTO structs
```

Rules:

- `<ServiceName>Setup/` contains the `*Setup` file
- `<ServiceName>Provider/` contains the `*Provider` file
- `Responses/` exists only if the service has response structs
- `DTOs/` exists only if the service has DTO structs
- if there is no response, do not create `Responses/`
- if there is no DTO, do not create `DTOs/`

Full example:

```text
CheckoutFlow/
├─ Domain/
│  ├─ Providers/
│  │  ├─ CardTokenProviderProtocol.swift
│  │  └─ PaymentsProviderProtocol.swift
│  └─ Models/
│     ├─ CardToken.swift
│     └─ PaymentSession.swift
└─ Data/
   └─ APIs/
      ├─ TokensAPI/
      │  ├─ TokensAPISetup/
      │  │  └─ TokensAPISetup.swift
      │  ├─ TokensAPIProvider/
      │  │  └─ TokensAPIProvider.swift
      │  ├─ Responses/
      │  │  └─ CardTokenResponse.swift
      │  └─ DTOs/
      │     └─ CreateCardTokenDTO.swift
      └─ PaymentsAPI/
         ├─ PaymentsAPISetup/
         │  └─ PaymentsAPISetup.swift
         ├─ PaymentsAPIProvider/
         │  └─ PaymentsAPIProvider.swift
         ├─ Responses/
         │  └─ CreatePaymentResponse.swift
         └─ DTOs/
            └─ CreatePaymentDTO.swift
```

## Naming conventions

### `*Setup`

Any type conforming to `ApiSetupProtocol` must end with `Setup`.

A `Setup` owns only request configuration:

- path
- method
- headers
- body
- query items
- request construction

Examples:

- `TokensAPISetup`
- `PaymentsAPISetup`
- `ProfileAPISetup`

### `*Provider`

Any type executing the request must end with `Provider`.

A `Provider` must:

- receive dependencies such as `baseURL`, `apiAccessProvider`, and `session`
- build the correct `Setup`
- execute the request
- decode the transport response
- map transport models into domain models
- return the mapped domain result
- conform to the domain protocol when a protocol exists

Examples:

- `TokensAPIProvider`
- `PaymentsAPIProvider`
- `ProfileAPIProvider`

### Domain protocols

Protocols in `Domain/Providers/` should represent feature capabilities.

Preferred names:

- `CardTokenProviderProtocol`
- `PaymentsProviderProtocol`
- `ProfileProviderProtocol`

Avoid naming the domain protocol after the raw vendor unless explicitly requested.

### DTOs and responses

Use these transport naming rules:

- request payloads and request parameter models: `*DTO`
- API response models: `*Response`

Examples:

- `CreateCardTokenDTO`
- `CreatePaymentDTO`
- `CardTokenResponse`
- `CreatePaymentResponse`

## Domain mapping rule

For each response model that maps to a domain model, add a mapper extension in the `Data` layer.

Use this exact style:

```swift
extension ExampleResponse {
    var domain: ExampleDomainModel {
        ExampleDomainModel(...)
    }
}
```

Rules:

- the mapper must live in the `Data` layer
- the computed property must be named `domain`
- providers must return domain models, not raw transport responses
- arrays must be mapped before returning

## Testing rule

Generated tests must:

- test the concrete `Provider`
- use `MockedURLSession` when JSON-backed transport testing is needed
- validate request setup, decoding, and domain mapping
- keep fixtures aligned with the real example JSON when available

Concrete spies are optional. Generate them only when they simplify the test surface or the consumer explicitly asks for them.

## Output rule

The final deliverable must be a **zip file** containing the generated root folder.
