## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


##
sad:
data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/Pjxzdmcgd2lkdGg9IjEwMjRweCIgaGVpZ2h0PSIxMDI0cHgiIHZpZXdCb3g9IjAgMCAxMDI0IDEwMjQiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZmlsbD0iIzMzMyIgZD0iTTUxMiA2NEMyNjQuNiA2NCA2NCAyNjQuNiA2NCA1MTJzMjAwLjYgNDQ4IDQ0OCA0NDggNDQ4LTIwMC42IDQ0OC00NDhTNzU5LjQgNjQgNTEyIDY0em0wIDgyMGMtMjA1LjQgMC0zNzItMTY2LjYtMzcyLTM3MnMxNjYuNi0zNzIgMzcyLTM3MiAzNzIgMTY2LjYgMzcyIDM3Mi0xNjYuNiAzNzItMzcyIDM3MnoiLz48cGF0aCBmaWxsPSIjRTZFNkU2IiBkPSJNNTEyIDE0MGMtMjA1LjQgMC0zNzIgMTY2LjYtMzcyIDM3MnMxNjYuNiAzNzIgMzcyIDM3MiAzNzItMTY2LjYgMzcyLTM3Mi0xNjYuNi0zNzItMzcyLTM3MnpNMjg4IDQyMWE0OC4wMSA0OC4wMSAwIDAgMSA5NiAwIDQ4LjAxIDQ4LjAxIDAgMCAxLTk2IDB6bTM3NiAyNzJoLTQ4LjFjLTQuMiAwLTcuOC0zLjItOC4xLTcuNEM2MDQgNjM2LjEgNTYyLjUgNTk3IDUxMiA1OTdzLTkyLjEgMzkuMS05NS44IDg4LjZjLS4zIDQuMi0zLjkgNy40LTguMSA3LjRIMzYwYTggOCAwIDAgMS04LTguNGM0LjQtODQuMyA3NC41LTE1MS42IDE2MC0xNTEuNnMxNTUuNiA2Ny4zIDE2MCAxNTEuNmE4IDggMCAwIDEtOCA4LjR6bTI0LTIyNGE0OC4wMSA0OC4wMSAwIDAgMSAwLTk2IDQ4LjAxIDQ4LjAxIDAgMCAxIDAgOTZ6Ii8+PHBhdGggZmlsbD0iIzMzMyIgZD0iTTI4OCA0MjFhNDggNDggMCAxIDAgOTYgMCA0OCA0OCAwIDEgMC05NiAwem0yMjQgMTEyYy04NS41IDAtMTU1LjYgNjcuMy0xNjAgMTUxLjZhOCA4IDAgMCAwIDggOC40aDQ4LjFjNC4yIDAgNy44LTMuMiA4LjEtNy40IDMuNy00OS41IDQ1LjMtODguNiA5NS44LTg4LjZzOTIgMzkuMSA5NS44IDg4LjZjLjMgNC4yIDMuOSA3LjQgOC4xIDcuNEg2NjRhOCA4IDAgMCAwIDgtOC40QzY2Ny42IDYwMC4zIDU5Ny41IDUzMyA1MTIgNTMzem0xMjgtMTEyYTQ4IDQ4IDAgMSAwIDk2IDAgNDggNDggMCAxIDAtOTYgMHoiLz48L3N2Zz4=

happy:
data:image/svg+xml;base64,
PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgZmlsbD0ieWVsbG93IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNjEiIGN5PSI4MiIgcj0iMTIiLz4KICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJtMTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+Cjwvc3ZnPg==