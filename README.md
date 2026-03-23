# iOSCleanNetwork

## AI-first use case

This repository is meant to be used in an **AI-first** workflow.

If you want an AI agent to generate integration code on top of this framework, give the agent:

1. this repository URL
2. the API documentation, PDF, OpenAPI file, or endpoint description
3. sample request and response JSON when available

Before generating anything, the AI must read [`README_AI.md`](./README_AI.md).

`README_AI.md` defines the required output format, folder structure, naming rules, and testing expectations for generated code.

## What the AI should generate

The AI should generate the integration files that a developer would normally create on top of `iOSCleanNetwork`, such as:

- domain provider protocols
- domain models
- `*Setup` types
- `*Provider` types
- DTOs
- response models
- domain mapper extensions
- JSON fixtures
- tests

The generated result must be delivered as a **zip file**.

Manual files are optional and should only be included when explicitly requested or when they are required to make the generated output understandable or testable.

## How to use the generated result

After the AI generates the output:

1. unzip it
2. inspect the structure
3. copy the generated folders into your host project or SDK
4. review the domain contracts, transport models, providers, and mappers
5. run the tests
6. wire the generated providers into your app or SDK

This README is also valid if you want to create the same structure manually instead of using AI generation.

## Required generated structure

The generated output must start with a **root folder named after the project**, feature, or something very similar.

Example:

```text
ProjectName/
├─ Domain/
└─ Data/
```

### Domain

`Domain` must contain exactly these two folders:

```text
Domain/
├─ Providers/
└─ Models/
```

Rules:

- `Domain/Providers/` contains only the **protocols of the features**
- `Domain/Models/` contains only the **domain model structs**
- no DTOs in `Domain`
- no response models in `Domain`
- no concrete API implementation in `Domain`

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

### Data

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

Inside each service folder, the structure must be:

```text
<ServiceName>/
├─ <ServiceName>Setup/
├─ <ServiceName>Provider/
├─ Responses/    // only if there are response models
└─ DTOs/         // only if there are DTOs
```

Rules:

- `<ServiceName>Setup/` contains the `*Setup` file for that service
- `<ServiceName>Provider/` contains the `*Provider` file for that service
- `Responses/` must exist only if the service has response structs
- `DTOs/` must exist only if the service has DTO structs
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

A `Setup` is responsible only for request configuration:

- path
- method
- headers
- body
- query items
- request creation

Examples:

- `TokensAPISetup`
- `PaymentsAPISetup`
- `ProfileAPISetup`

### `*Provider`

Any request executor must end with `Provider`.

A `Provider` is responsible for:

- receiving dependencies such as `baseURL`, `apiAccessProvider`, and `session`
- building the correct `Setup`
- performing the request
- decoding the response
- mapping transport models into domain models
- returning domain models

Examples:

- `TokensAPIProvider`
- `PaymentsAPIProvider`
- `ProfileAPIProvider`

### Domain provider protocols

Protocols in `Domain/Providers/` should describe the feature capability.

Examples:

- `CardTokenProviderProtocol`
- `PaymentsProviderProtocol`
- `ProfileProviderProtocol`

These are protocols only. Concrete implementations stay in `Data`.

### DTOs and responses

Use these names consistently:

- request payloads: `*DTO`
- API responses: `*Response`

Examples:

- `CreateCardTokenDTO`
- `CreatePaymentDTO`
- `CardTokenResponse`
- `CreatePaymentResponse`

### Domain mapper extension

When a response model maps into a domain model, the mapper should live in the `Data` layer and use a computed property named `domain`.

Example:

```swift
extension CardTokenResponse {
    var domain: CardToken {
        CardToken(token: token)
    }
}
```

## Testing expectations

Generated tests should:

- use `MockedURLSession` when JSON-backed transport testing is needed
- test the concrete `Provider`
- verify request setup, decoding, and mapping
- keep JSON fixtures close to the related feature when possible

Concrete spies are optional and should be added only when they improve clarity or simplify assertions.
