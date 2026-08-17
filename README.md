# RED

### A Modular Virtual-Engine Intelligence System

> **Five specialized engines. One administrative core. One unified system.**

**Red** is a modular intelligent-system architecture built around five specialized virtual engines — **Frontman, Ghost, Oracle, Keeper, and Sentinel** — coordinated and governed by a privileged administrative engine called **Zade**.

Rather than building a single monolithic AI agent responsible for every operation, Red separates interaction, execution, intelligence, memory, and security into independent conceptual engines.

This architecture is designed to create a system that can **think, remember, act, communicate, observe, and govern itself through clearly separated responsibilities**.

---

## Table of Contents

* [What is Red?](#what-is-red)
* [The Core Idea](#the-core-idea)
* [The Six Engines](#the-six-engines)

  * [Frontman](#1-frontman)
  * [Ghost](#2-ghost)
  * [Oracle](#3-oracle)
  * [Keeper](#4-keeper)
  * [Sentinel](#5-sentinel)
  * [Zade](#6-zade)
* [How the Engines Work Together](#how-the-engines-work-together)
* [Architecture](#architecture)
* [Engine Responsibilities](#engine-responsibilities)
* [Request Lifecycle](#request-lifecycle)
* [Intelligence Layer](#intelligence-layer)
* [Memory Architecture](#memory-architecture)
* [Execution Architecture](#execution-architecture)
* [Security Architecture](#security-architecture)
* [Administrative Control](#administrative-control)
* [Real-Time Infrastructure](#real-time-infrastructure)
* [Current Platform Capabilities](#current-platform-capabilities)
* [Technology Stack](#technology-stack)
* [Project Structure](#project-structure)
* [Data Architecture](#data-architecture)
* [Development](#development)
* [Testing](#testing)
* [Design Principles](#design-principles)
* [Why Multiple Engines?](#why-multiple-engines)
* [Roadmap](#roadmap)
* [Project Status](#project-status)
* [Author](#author)

---

# What is Red?

Red is an attempt to answer a broader question:

> **What would an intelligent software system look like if its capabilities were separated into specialized virtual entities instead of being placed inside one enormous agent?**

Most AI applications follow a relatively simple architecture:

```text
User
 │
 ▼
AI Agent
 │
 ├── Think
 ├── Remember
 ├── Execute
 ├── Communicate
 └── Monitor
```

Red approaches the same problem differently.

```text
                         ┌──────────────────┐
                         │       ZADE       │
                         │ ADMINISTRATION   │
                         └────────┬─────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
              ▼                   ▼                   ▼
        ┌───────────┐      ┌───────────┐       ┌───────────┐
        │ FRONTMAN  │      │  SENTINEL │       │   GHOST   │
        │ Interaction│     │ Security  │       │ Execution │
        └─────┬─────┘      └───────────┘       └─────┬─────┘
              │                                      │
              │             ┌───────────┐            │
              └────────────►│  ORACLE   │◄───────────┘
                            │Intelligence│
                            └─────┬─────┘
                                  │
                            ┌─────▼─────┐
                            │  KEEPER   │
                            │Memory/State│
                            └───────────┘
```

Each engine has a distinct responsibility.

The result is intended to be easier to reason about, secure, extend, debug, and evolve.

---

# The Core Idea

Red is built around six virtual engines.

Five are operational:

| Engine       | Primary Role                                 |
| ------------ | -------------------------------------------- |
| **Frontman** | Human interaction and communication          |
| **Ghost**    | Background execution and operations          |
| **Oracle**   | Intelligence, reasoning, and decision-making |
| **Keeper**   | Memory, state, and persistent knowledge      |
| **Sentinel** | Security, monitoring, and protection         |

One is administrative:

| Engine   | Primary Role                                                  |
| -------- | ------------------------------------------------------------- |
| **Zade** | System administration, governance, configuration, and control |

The important distinction is that **Zade is not simply another agent**.

It exists above the operational engines.

---

# The Six Engines

## 1. Frontman

### The Human Interface

**Frontman** is the primary interface between humans and Red.

Its responsibility is to understand what the user wants and translate human interaction into structured system requests.

### Responsibilities

* User interaction
* Request interpretation
* Intent extraction
* Conversation handling
* Response generation/presentation
* User-facing workflows
* Request routing
* Contextual interaction

Conceptually:

```text
Human
  │
  ▼
Frontman
  │
  ▼
Structured Intent
```

Frontman should not need to know how every internal subsystem works.

Its job is to communicate with the human world.

---

# 2. Ghost

### The Execution Engine

**Ghost** is Red's operational engine.

While Frontman handles interaction, Ghost is responsible for performing tasks that happen behind the scenes.

Ghost represents the principle:

> **The system should be able to act without exposing every internal operation to the user.**

### Responsibilities

Potential responsibilities include:

* Background jobs
* Task execution
* Automation
* Tool invocation
* External service interaction
* Long-running operations
* Scheduled operations
* Data processing
* System workflows

Conceptually:

```text
Instruction
     │
     ▼
   Ghost
     │
     ├── Tool
     ├── API
     ├── Process
     ├── Job
     └── Workflow
```

Ghost is the **hands** of Red.

---

# 3. Oracle

### The Intelligence Engine

**Oracle** is the reasoning and intelligence layer.

It is responsible for understanding information, evaluating context, reasoning over available data, and producing decisions or recommendations.

Oracle represents:

> **What does Red understand?**

### Responsibilities

Potential responsibilities include:

* Reasoning
* Analysis
* Context interpretation
* Knowledge synthesis
* Decision-making
* Planning
* Model orchestration
* Information extraction
* Problem solving

Conceptually:

```text
Information
     │
     ▼
   Oracle
     │
     ├── Understand
     ├── Analyze
     ├── Reason
     ├── Plan
     └── Decide
```

Oracle is the **mind** of Red.

---

# 4. Keeper

### The Memory Engine

**Keeper** is responsible for information that must persist.

An intelligent system without persistent state repeatedly forgets everything it learns about its environment.

Keeper exists to solve that problem.

### Responsibilities

* Persistent memory
* User context
* System state
* Historical information
* Knowledge storage
* Retrieval
* Context persistence
* State synchronization
* Information versioning

Conceptually:

```text
               KEEPER
                  │
       ┌──────────┼──────────┐
       ▼          ▼          ▼
     Memory     State     Knowledge
       │          │          │
       └──────────┼──────────┘
                  ▼
              Retrieval
```

Keeper is the **memory** of Red.

---

# 5. Sentinel

### The Security and Observation Engine

**Sentinel** exists to observe the system.

Its purpose is to make security and system integrity an architectural concern rather than an afterthought.

### Responsibilities

* Security monitoring
* Permission enforcement
* Threat detection
* Anomaly detection
* Activity monitoring
* Audit information
* System health
* Policy enforcement
* Runtime observation

Conceptually:

```text
                    SENTINEL
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
     Security       Runtime        Activity
     Events         Health          Events
        │              │              │
        └──────────────┼──────────────┘
                       ▼
                   Evaluation
```

Sentinel is the **watcher** of Red.

---

# 6. Zade

### The Administrative Engine

**Zade** is the administrative core of Red.

Unlike the other engines, Zade exists primarily for **governance and control**.

It is the layer that manages the system itself.

### Responsibilities

* Engine configuration
* Engine lifecycle management
* Permissions
* Policies
* Administrative operations
* System diagnostics
* Configuration management
* Runtime control
* Engine coordination
* System-level decisions

Conceptually:

```text
                         ZADE
                          │
             ┌────────────┼────────────┐
             ▼            ▼            ▼
          CONFIG       POLICY       CONTROL
             │            │            │
             └────────────┼────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
      FRONTMAN          ORACLE          GHOST
          │               │               │
       KEEPER          SENTINEL        SERVICES
```

Zade is the **control plane**.

The other five engines form the operational plane.

---

# How the Engines Work Together

A Red operation can conceptually look like this:

```text
                        USER
                         │
                         ▼
                    ┌─────────┐
                    │FRONTMAN │
                    └────┬────┘
                         │
                    User Intent
                         │
                         ▼
                    ┌─────────┐
                    │ ORACLE  │
                    └────┬────┘
                         │
                 Reasoning / Planning
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
          ┌──────┐   ┌──────┐   ┌─────────┐
          │KEEPER│   │ GHOST│   │SENTINEL │
          └──┬───┘   └───┬──┘   └────┬────┘
             │           │            │
           Memory     Execution     Security
             │           │            │
             └───────────┼────────────┘
                         ▼
                    ┌─────────┐
                    │FRONTMAN │
                    └────┬────┘
                         │
                         ▼
                        USER
```

Zade remains above the architecture:

```text
                     ZADE
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   Configuration   Policy       Administration
```

---

# Architecture

Red follows a separation between **control**, **intelligence**, **execution**, **memory**, **interaction**, and **security**.

```text
┌──────────────────────────────────────────────────────────┐
│                         ZADe                             │
│                 Administrative Control                  │
└───────────────────────────┬──────────────────────────────┘
                            │
════════════════════════════╪══════════════════════════════
                            │
                    OPERATIONAL LAYER
                            │
      ┌──────────┬──────────┼──────────┬──────────┐
      │          │          │          │          │
      ▼          ▼          ▼          ▼          ▼
 Frontman      Ghost      Oracle     Keeper    Sentinel
Interaction   Execute    Reason     Remember   Protect
      │          │          │          │          │
      └──────────┴──────────┴──────────┴──────────┘
                            │
                            ▼
                    External Systems
```

---

# Engine Responsibilities

The separation can be summarized as:

```text
┌────────────┬─────────────────────────────────────────┐
│ Engine     │ Responsibility                          │
├────────────┼─────────────────────────────────────────┤
│ Frontman   │ Human interaction and communication     │
│ Ghost      │ Execution and automation                │
│ Oracle     │ Intelligence and reasoning             │
│ Keeper     │ Memory and persistent state             │
│ Sentinel   │ Security and observation               │
│ Zade       │ Administration and system governance   │
└────────────┴─────────────────────────────────────────┘
```

Another way to think about them:

```text
Frontman  → Communicate
Oracle    → Think
Keeper    → Remember
Ghost     → Act
Sentinel  → Watch
Zade      → Control
```

---

# Request Lifecycle

A normal interaction can follow a lifecycle similar to:

### 1. Input

The user interacts with Red.

```text
User → Frontman
```

### 2. Interpretation

Frontman converts the interaction into a structured request.

```text
Frontman → Intent
```

### 3. Context Retrieval

Keeper provides relevant persistent information.

```text
Intent → Keeper → Context
```

### 4. Reasoning

Oracle analyzes the request using the available context.

```text
Context + Intent → Oracle
```

### 5. Planning

Oracle determines what should happen.

```text
Oracle → Plan
```

### 6. Execution

Ghost performs actions required by the plan.

```text
Plan → Ghost → Execution
```

### 7. Validation

Sentinel observes and evaluates the operation.

```text
Execution → Sentinel
```

### 8. Persistence

Keeper stores relevant resulting information.

```text
Result → Keeper
```

### 9. Response

Frontman communicates the result.

```text
Result → Frontman → User
```

---

# Intelligence Layer

Oracle is not intended to operate in isolation.

A useful intelligence architecture requires access to:

```text
                   ORACLE
                     │
       ┌─────────────┼─────────────┐
       ▼             ▼             ▼
    Context       Memory         Tools
       │             │             │
       └─────────────┼─────────────┘
                     ▼
                  Reasoning
                     │
                     ▼
                   Plan
```

This allows intelligence to be separated from execution.

Oracle decides **what should happen**.

Ghost handles **how it happens**.

That distinction is fundamental to the architecture.

---

# Memory Architecture

Keeper is responsible for separating short-lived execution context from information that should persist.

A conceptual memory hierarchy:

```text
                   KEEPER
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
    Short-Term    Persistent    Knowledge
     Context       State        Records
        │            │            │
        └────────────┼────────────┘
                     ▼
                  Retrieval
                     │
                     ▼
                   Oracle
```

This separation allows the intelligence layer to retrieve only the context required for a particular operation.

---

# Execution Architecture

Ghost is intentionally separated from Oracle.

```text
              ORACLE
                 │
              Decision
                 │
                 ▼
              ┌──────┐
              │GHOST │
              └──┬───┘
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
     APIs      Tools     Jobs
       │         │         │
       └─────────┼─────────┘
                 ▼
              Result
```

This separation is important because reasoning and execution have different security requirements.

An engine capable of reasoning about an operation does not automatically need unrestricted permission to execute it.

---

# Security Architecture

Sentinel provides an independent security boundary.

The intended model is:

```text
Request
   │
   ▼
Authentication
   │
   ▼
Authorization
   │
   ▼
Engine Permission
   │
   ▼
Execution
   │
   ▼
Sentinel Observation
   │
   ▼
Audit / Policy
```

Red's existing application foundation includes **WebAuthn/Passkey authentication**, secure session-token handling, and system telemetry.

The engine architecture is intended to extend those security principles beyond user authentication into engine-level authorization.

---

# Administrative Control

Zade should be treated as a privileged control plane.

```text
                    ZADE
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
     Engines       Policies     Runtime
        │            │            │
        ▼            ▼            ▼
   Lifecycle      Access       Diagnostics
```

Possible administrative operations include:

* Enable/disable an engine
* Change engine configuration
* Modify permissions
* Inspect engine health
* Review system events
* Manage policies
* Trigger maintenance
* Control background processes
* Inspect system state

The separation is deliberate:

> **Operational engines operate inside the system. Zade governs the system.**

---

# Real-Time Infrastructure

Red is built on **Elixir/Phoenix**, making real-time communication a first-class architectural capability.

The current application uses Phoenix PubSub and Telemetry for event-driven communication and observability.

Conceptually:

```text
                 Event
                   │
                   ▼
              Phoenix PubSub
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
     Frontman    Ghost      Sentinel
        │          │          │
        └──────────┼──────────┘
                   ▼
                 State
```

This provides a foundation for future engine-to-engine communication without requiring every component to directly depend on every other component.

---

# Current Platform Capabilities

Although Red's long-term identity is the engine architecture, the current codebase already contains several substantial platform capabilities.

## Identity

The project contains a passwordless authentication architecture based on WebAuthn/Passkeys.

This includes:

* Registration
* Authentication
* Identity management
* Secure session tokens
* Token cleanup

---

## Social Layer

The current application includes social mechanics such as:

* User following
* Unfollowing
* Relationship validation
* Personalized timelines
* Post creation
* Post editing
* Post deletion

The following relationship is protected with database-level uniqueness constraints.

---

## Timeline Engine

The timeline system can construct personalized feeds containing posts from the user and accounts they follow.

The feed supports pagination through limit/offset parameters and uses Ecto queries/subqueries for feed generation.

---

## Real-Time Posts

Post operations can broadcast events through Phoenix PubSub.

This provides the basis for real-time updates rather than requiring clients to repeatedly poll the server.

---

## Projects

The platform contains a project/workspace domain supporting:

* Projects
* Project members
* Collaborative project relationships

---

## Vault

The Vault subsystem provides a model for:

* Files
* File records
* File versions
* Persistent file snapshots

---

## Discussions

The platform contains a discussion system consisting of:

```text
Thread
  │
  ├── Comment
  ├── Comment
  └── Comment
```

This creates a more structured communication layer separate from the fast-moving social timeline.

---

## Marketplace

Red also contains the foundation for an open marketplace with listings representing products, services, hardware, or other resources.

---

## Events

The Events domain provides a foundation for community competitions and hackathons.

---

# Technology Stack

## Core

| Technology           | Purpose                       |
| -------------------- | ----------------------------- |
| **Elixir**           | Core application language     |
| **Phoenix**          | Web/application framework     |
| **Phoenix LiveView** | Real-time interactive UI      |
| **Ecto**             | Database abstraction          |
| **PostgreSQL**       | Persistent relational storage |
| **Erlang/OTP**       | Concurrency and runtime       |

## Security

| Technology         | Purpose                     |
| ------------------ | --------------------------- |
| **WebAuthn**       | Passwordless authentication |
| **Passkeys**       | User identity               |
| **Session Tokens** | Authenticated sessions      |

## Real-Time

| Technology         | Purpose            |
| ------------------ | ------------------ |
| **Phoenix PubSub** | Event distribution |
| **Telemetry**      | Observability      |
| **LiveDashboard**  | Runtime monitoring |

## Background Processing

| Technology | Purpose         |
| ---------- | --------------- |
| **Oban**   | Background jobs |

## Frontend

| Technology       | Purpose         |
| ---------------- | --------------- |
| **Tailwind CSS** | Styling         |
| **esbuild**      | Asset bundling  |
| **Heroicons**    | Interface icons |

The current dependency configuration includes Phoenix 1.8, Phoenix LiveView, Ecto, PostgreSQL/Postgrex, WebAuthn components, Oban, Telemetry, Bandit, Tailwind, and esbuild.

---

# Why Elixir and Phoenix?

Red's architecture is heavily oriented around:

* Concurrent operations
* Persistent connections
* Real-time events
* Background processing
* Fault isolation
* Distributed workloads
* Long-running processes

These characteristics align naturally with the BEAM ecosystem.

Phoenix additionally provides:

* LiveView
* PubSub
* Channels
* Telemetry
* LiveDashboard
* Strong OTP integration

This makes Elixir/Phoenix a deliberate architectural choice rather than simply a framework preference.

---

# Data Architecture

The current platform uses PostgreSQL through Ecto.

Conceptually, the data model contains domains such as:

```text
Users
 │
 ├── Following
 │
 ├── Posts
 │
 ├── Projects
 │      └── Project Members
 │
 ├── Files
 │      └── File Versions
 │
 ├── Discussions
 │      ├── Threads
 │      └── Comments
 │
 ├── Marketplace Listings
 │
 └── Events
        └── Hackathons
```

This domain-oriented organization allows each subsystem to evolve independently.

---

# Observability

Red uses Telemetry as part of its runtime architecture.

Important application events can be represented as telemetry events, allowing the system to expose operational information through Phoenix's monitoring ecosystem.

This is particularly useful for an engine-based architecture because eventually each engine can expose:

```text
Engine
 │
 ├── Health
 ├── Latency
 ├── Requests
 ├── Errors
 ├── Events
 └── Resource Usage
```

---

# Fault Isolation

One of the major reasons for separating Red into engines is fault containment.

The desired architecture is:

```text
       Engine Failure
             │
             ▼
      ┌─────────────┐
      │   Sentinel  │
      └──────┬──────┘
             │
             ▼
        Detect / Record
             │
             ▼
          Zade
             │
      ┌──────┴──────┐
      ▼             ▼
   Recover       Disable
```

A failure in Ghost should not necessarily destroy Oracle.

A problem in Oracle should not necessarily disable Sentinel.

A temporary Keeper failure should not automatically compromise Frontman.

This is one of the central architectural goals of Red.

---

# Engine Isolation

Each engine should ideally have:

1. A defined responsibility
2. A defined input interface
3. A defined output interface
4. Explicit permissions
5. Limited access to other engines
6. Independent failure handling
7. Observable runtime behavior

Conceptually:

```text
┌─────────────────────────┐
│        ENGINE           │
│                         │
│  Input                  │
│    ↓                    │
│  Processing             │
│    ↓                    │
│  Output                 │
│                         │
│  Permissions            │
│  Health                 │
│  Telemetry              │
└─────────────────────────┘
```

This creates a foundation for treating engines as actual system components rather than simply names assigned to different pieces of code.

---

# Engine Communication

Red should avoid unrestricted direct communication between every engine.

Instead:

```text
BAD

Frontman ────────► Everything
Oracle ──────────► Everything
Ghost ───────────► Everything
Keeper ──────────► Everything
Sentinel ────────► Everything
```

The preferred direction is:

```text
                    ZADE
                      │
                 Governance
                      │
              ┌───────┴───────┐
              │               │
          Event Bus       Permission
              │               │
     ┌────────┼────────┬──────┼───────┐
     ▼        ▼        ▼      ▼       ▼
 Frontman   Ghost    Oracle Keeper  Sentinel
```

This makes interactions explicit and auditable.

---

# Development Philosophy

Red is being developed around a few fundamental principles.

## 1. Specialization

An engine should be good at one category of work instead of being responsible for everything.

## 2. Least Privilege

No engine should have permissions it does not need.

## 3. Explicit Communication

Engine interactions should happen through defined interfaces.

## 4. Observability

Important engine behavior should be measurable.

## 5. Fault Isolation

Individual failures should be contained whenever possible.

## 6. Human Authority

The system should remain administratively controllable.

## 7. Extensibility

New engines should be possible without rewriting the entire architecture.

---

# Development Setup

## Requirements

You will need:

* Elixir
* Erlang/OTP
* PostgreSQL
* Git

---

## Clone

```bash
git clone https://github.com/Sakho115/red.git
cd red
```

---

## Install Dependencies

```bash
mix setup
```

The project's setup alias handles dependency installation, database setup, migrations, seeds, and frontend asset preparation.

---

## Start Development Server

```bash
mix phx.server
```

Or:

```bash
iex -S mix phx.server
```

Then visit:

```text
http://localhost:4000
```

---

# Testing

Run the test suite:

```bash
mix test
```

For the project's precommit checks:

```bash
mix precommit
```

The precommit workflow includes compilation with warnings treated as errors, dependency cleanup, formatting, and tests.

---

# Production Assets

Build production assets with:

```bash
mix assets.deploy
```

The configured asset pipeline handles Tailwind, esbuild, and Phoenix digest generation.

---

# Project Structure

The repository currently follows the Phoenix project structure:

```text
red/
│
├── .github/
│
├── assets/
│
├── config/
│
├── lib/
│   └── eng_hub/
│
├── priv/
│   └── repo/
│
├── test/
│
├── .formatter.exs
├── .gitignore
├── mix.exs
├── mix.lock
│
├── README.md
│
├── desc.txt
├── logic.txt
├── problems.txt
├── steps.txt
│
└── test output / development artifacts
```

The current repository contains substantial architectural notes and testing/development artifacts alongside the Phoenix application.

---

# Roadmap

Red's long-term architecture can evolve through several stages.

## Phase I — Foundation

* [x] Phoenix foundation
* [x] PostgreSQL integration
* [x] WebAuthn foundation
* [x] Passkey authentication
* [x] Social domain
* [x] Timeline domain
* [x] Project domain
* [x] Discussion domain
* [x] Vault foundation
* [x] Marketplace foundation
* [x] Events foundation
* [x] PubSub infrastructure
* [x] Telemetry infrastructure

---

## Phase II — Engineization

* [ ] Formalize Frontman interface
* [ ] Formalize Ghost execution layer
* [ ] Formalize Oracle reasoning layer
* [ ] Formalize Keeper memory layer
* [ ] Formalize Sentinel security layer
* [ ] Formalize Zade control plane
* [ ] Define engine contracts
* [ ] Define engine permissions
* [ ] Define engine lifecycle management

---

## Phase III — Intelligence

* [ ] LLM provider abstraction
* [ ] Model routing
* [ ] Structured reasoning
* [ ] Tool calling
* [ ] Context retrieval
* [ ] Persistent memory
* [ ] Planning
* [ ] Multi-step execution

---

## Phase IV — Autonomous Operations

* [ ] Background agent workflows
* [ ] Scheduled tasks
* [ ] Long-running operations
* [ ] Engine-to-engine event routing
* [ ] Autonomous task execution
* [ ] Recovery workflows
* [ ] Failure isolation

---

## Phase V — Security

* [ ] Engine-level authorization
* [ ] Capability-based permissions
* [ ] Security policies
* [ ] Runtime anomaly detection
* [ ] Engine audit trails
* [ ] Administrative controls
* [ ] Security event correlation

---

## Phase VI — Distributed Red

Longer term, individual engines could potentially run as independently scalable processes or services.

```text
                    ZADE
                      │
                 Control Plane
                      │
       ┌──────────────┼──────────────┐
       │              │              │
       ▼              ▼              ▼
   Frontman        Oracle         Sentinel
       │              │              │
       ▼              ▼              ▼
     Ghost          Keeper        Security
       │              │
       └──────────────┘
              │
        Distributed Runtime
```

The objective would be to scale different capabilities independently.

---

# What Red Is Not

Red is not intended to be:

* Just a chatbot
* A single LLM wrapper
* A simple automation script
* A collection of unrelated microservices
* A conventional social network
* A generic AI assistant

The central idea is the **engine architecture**.

Social networking, projects, storage, discussions, marketplaces, and events are supporting capabilities around that architecture.

---

# Red's Conceptual Model

The simplest way to understand Red is:

```text
                    ┌───────────────┐
                    │     ZADe      │
                    │    Govern     │
                    └───────┬───────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
   ┌─────────┐         ┌─────────┐         ┌─────────┐
   │FRONTMAN │         │ ORACLE  │         │  GHOST  │
   │Communicate│       │  Think  │         │   Act   │
   └────┬────┘         └────┬────┘         └────┬────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                    ┌───────▼───────┐
                    │    KEEPER     │
                    │    Remember   │
                    └───────┬───────┘
                            │
                    ┌───────▼───────┐
                    │   SENTINEL    │
                    │    Protect    │
                    └───────────────┘
```

Or, in six words:

> **Frontman communicates. Oracle thinks. Ghost acts. Keeper remembers. Sentinel protects. Zade governs.**

---

# Current Status

> **Experimental Architecture / Active Development**

Red is a long-term project exploring modular intelligent-system architecture.

The existing Phoenix application provides a working foundation for identity, social interaction, feeds, projects, storage, discussions, marketplace functionality, events, real-time communication, background processing, and observability.

The next major step is turning the conceptual engine model into a formally isolated runtime architecture.

---

# Why Red?

The name **Red** represents the system as a whole rather than any individual engine.

The engines are not separate products.

They are components of one system.

```text
                 RED
                  │
      ┌───────────┼───────────┐
      │           │           │
   Intelligence  Memory    Execution
      │           │           │
    Oracle      Keeper      Ghost
      │           │           │
      └───────────┼───────────┘
                  │
          ┌───────┴───────┐
          │               │
      Frontman         Sentinel
      Interface        Security
          │               │
          └───────┬───────┘
                  │
                 Zade
               Control
```

**Red is the system.**

The engines are its capabilities.

---

# Author

**Sakho115**

Creator and primary developer of Red.

GitHub:
[https://github.com/Sakho115](https://github.com/Sakho115)

---

# License

See the repository's license for the current terms governing use, modification, and distribution.

---

## Final Architecture

```text
                           ┌─────────────────────┐
                           │        ZADE         │
                           │  ADMIN / CONTROL    │
                           │                     │
                           │  Policies           │
                           │  Configuration      │
                           │  Permissions        │
                           │  Diagnostics        │
                           └──────────┬──────────┘
                                      │
                       ───────────────┼───────────────
                                      │
                              RED ENGINE CORE
                                      │
        ┌─────────────────┬───────────┼───────────┬─────────────────┐
        │                 │           │           │                 │
        ▼                 ▼           ▼           ▼                 ▼
 ┌─────────────┐   ┌───────────┐ ┌─────────┐ ┌──────────┐ ┌─────────────┐
 │  FRONTMAN   │   │   GHOST   │ │ ORACLE  │ │  KEEPER  │ │  SENTINEL   │
 │             │   │           │ │         │ │          │ │             │
 │ Interaction │   │ Execution │ │Intelligence│ Memory │ │  Security   │
 │ Conversation│   │ Automation│ │ Reasoning│ │ State  │ │ Monitoring  │
 │ User Layer  │   │ Tooling   │ │ Planning│ │Knowledge│ │ Protection  │
 └──────┬──────┘   └─────┬─────┘ └────┬────┘ └────┬─────┘ └──────┬──────┘
        │                 │            │            │              │
        └─────────────────┴────────────┴────────────┴──────────────┘
                                      │
                                      ▼
                           ┌─────────────────────┐
                           │   EXTERNAL WORLD    │
                           │                     │
                           │ APIs • Tools • Data │
                           │ Users • Services   │
                           └─────────────────────┘
```

**RED is an experiment in building software that doesn't just contain intelligence — it gives intelligence structure.**
