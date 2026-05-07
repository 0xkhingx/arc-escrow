# ARC Escrow

Trustless escrow for AI agent payments, built natively on Arc testnet.

## What It Does

ARC Escrow lets a payer lock USDC into a smart contract, release it to an agent when a task is completed, or dispute and reclaim funds if something goes wrong. Every escrow is a fresh contract instance deployed through a factory — no shared state, no admin keys, no intermediaries.

Built specifically for Arc because Arc is the only chain where this makes sense: USDC-native gas, sub-second finality, and infrastructure designed for autonomous agent commerce.

## How It Works

1. Payer connects wallet and switches to Arc testnet automatically
2. Payer fills in agent address, task description, and USDC amount
3. Clicking **Lock Funds** deploys a fresh escrow contract via the factory, approves USDC, and deposits in three sequential transactions
4. Payer confirms completion to release funds to the agent, or disputes to freeze and eventually refund

### Contract Addresses

| Contract                    | Address                                      |
| --------------------------- | -------------------------------------------- |
| EscrowFactory (✅ Verified) | `0x2382d0E87F72534a4cA2D552Cf10A131bA2BC5CA` |
| USDC (native)               | `0x3600000000000000000000000000000000000000` |

## Tech Stack

- **Smart contracts:** Solidity + Foundry
- **Frontend:** React + Vite + ethers.js v6 + React Router
- **Network:** Arc Testnet
- **Read-only mode:** Public RPC fallback — browse agents and profiles without a wallet

## Agent Profiles

Every registered agent gets a permanent shareable profile page:

```
https://arc-escrow-app-psi.vercel.app/agent/0xYOUR_ADDRESS
```

## Run locally

```bash
git clone https://github.com/0xkhingx/arc-escrow
cd arc-escrow
forge build
forge test
```

Add Arc Testnet to MetaMask:

- RPC URL: `https://rpc.testnet.arc.network`
- Chain ID: `5042002`
- Currency: `USDC`
- Explorer: `https://testnet.arcscan.app`

Get test USDC from [Circle's faucet](https://faucet.circle.com).

## Contract architecture

EscrowFactory
└── createEscrow(agent, conditionHash)
├── deploys fresh Escrow instance
├── authorizes Escrow on AgentRegistry
└── returns Escrow address
Escrow
├── deposit(amount)
├── confirmCompletion() → pays agent + updates registry
├── dispute() → freezes funds + flags registry
└── refund() → returns funds to payer
AgentRegistry
├── register(name, description, serviceType)
├── recordCompletion(agent, amount) → onlyAuthorized
├── recordDispute(agent) → onlyAuthorized
└── getReputation(agent) → weighted score

## Why Arc

Most chains make agent payments awkward — volatile gas tokens, slow finality, unpredictable fees. Arc fixes all three:

- USDC as native gas — stable, predictable fees
- Sub-second finality — agent transactions settle fast
- Built by Circle, backed by BlackRock and Visa — institutional trust layer already in place

## Roadmap

- [ ] Arbitration layer for disputed escrows
- [ ] Multi-party escrows for complex agent workflows
- [ ] Agent credit scoring beyond job count
- [ ] Mainnet deployment when Arc launches 2026

## Frontend

Live app: [arc-escrow-app-psi.vercel.app](https://arc-escrow-app-psi.vercel.app)  
Frontend repo: [github.com/0xkhingx/arc-escrow-app](https://github.com/0xkhingx/arc-escrow-app)

Built by [@0xkhingx](https://github.com/0xkhingx) on Arc Testnet.
