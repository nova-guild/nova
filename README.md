<div align="center">
    <h1>
        <img height="150" src="./docs/public/nova.png" alt="Nova logo">
    </h1>
    <h3>
        A convention-driven, runtime-agnostic web framework for Luau.
    </h3>
    <a href="https://pesde.dev/packages/bizwiz3/nova"><img alt="Pesde Package" src="https://img.shields.io/badge/pesde-bizwiz3/nova-F19D1E?style=for-the-badge&labelColor=000"></a>
    <a href="https://nova-guild.github.io/nova/"><img alt="Nova Documentation" src="https://img.shields.io/badge/nova-documentation-8B5CF6?style=for-the-badge&labelColor=000"></a>
    <a href="https://github.com/nova-guild/nova/actions/workflows/ci.yml"><img alt="CI Status" src="https://img.shields.io/github/actions/workflow/status/nova-guild/nova/ci.yml?style=for-the-badge&label=CI&labelColor=000"></a>
</div>


###

# Getting Started

The fastest way to get a Nova project running is by using our scaffolding tool, but you can also set things up manually if you prefer.

## Prerequisites

Before we start, make sure you have the following installed:

- **A Luau Runtime:** [`Lune`](https://lune-org.github.io/docs/), [`Zune`](https://zune.sh/), or [`Lute`](https://lute.luau.org/).
- **A Package Manager:** We recommend [`pesde`](https://docs.pesde.dev/).

## Option 1: Using the CLI

We created a CLI tool that handles all the boilerplate for you. It sets up your folders, configures your package manager, and creates sample routes automatically.

Open your terminal and run:

```bash
# Scaffold into the current directory
pesde x nova/create -- .
```

or

```bash
# Scaffold into a new named directory. Replace 'my-app' with whatever you want to name your project
pesde x nova/create -- my-app
```