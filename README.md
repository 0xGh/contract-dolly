# Dolly

A smart contract that can clone your NFTs.

---

**Warning**! this is a proof of concept contract and hasn't been fully tested yet. Use it with caution.

---

The idea behind cloning an NFT is:

1. the clone contract allows the owner of the original NFT to create a copy (mint it)
2. the clone's `tokenURI` points to the original one and therefore returns the original metadata
3. the clone is controlled by the owner of the original NFT

## Development

The contract is developed using the [Truffle Suite](https://docs.openzeppelin.com/learn/setting-up-a-node-project). To develop the contract locally you need Node.js and npm/yarn.

Clone the repo and install the dependencies.

```shell
yarn install
# make change to contracts/Dolly.sol
yarn test
```

## Test

Tests are written in JavaScript and are under `test/dolly.js`. Please add more / contributions are welcome.

## Deploy

Use Remix (the Ethereum IDE) to deploy the contract.

- Create the files that you find in the `contracts` folder of this repository (ignore `mocks`)
- Compile `Dolly.sol`
- To deploy to testnet and mainnet you will need to select `Injected Web3`. You can get some ETH for Rinkeby (testnet) from https://faucets.chain.link
- Select the correct network (eg. Rinkeby) in your wallet
- Deploy `Dolly.sol`

For a quick guide on how to deploy with Remix check out [this tutorial](https://www.youtube.com/watch?v=ixMOXO-6Ia4) (ignore the specific example contract that the author creates).

## License

BSD 3-Clause License
