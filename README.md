ARC Escrow
Trustless escrow for AI agent payments, built natively on Arc testnet.
What it does
ARC Escrow lets a payer lock USDC into a smart contract, release it to an agent when a task is completed, or dispute and reclaim funds if something goes wrong. Every escrow is a fresh contract instance deployed through a factory — no shared state, no admin keys, no intermediaries.
Built specifically for Arc because Arc is the only chain where this makes sense: USDC-native gas, sub-second finality, and infrastructure designed for autonomous agent commerce.
How it works

Payer connects wallet and switches to Arc testnet automatically
Payer fills in agent address, task description, and USDC amount
Clicking Lock Funds deploys a fresh escrow contract via the factory, approves USDC, and deposits in three sequential transactions
Payer confirms completion to release funds to the agent, or disputes to freeze and eventually refund

Contracts
ContractAddressEscrowFactory0x2382d0E87F72534a4cA2D552Cf10A131bA2BC5CAUSDC (native)0x3600000000000000000000000000000000000000
Deployed on Arc Testnet (Chain ID: 5042002). Verify on Arcscan.
Tech stack

Smart contracts: Solidity + Foundry
Frontend: React + Vite + ethers.js
Network: Arc Testnet

Run locally
bash# Clone the frontend
git clone https://github.com/0xkhingx/arc-escrow-app
cd arc-escrow-app
npm install
npm run dev
Add Arc Testnet to MetaMask:

RPC URL: https://rpc.testnet.arc.network
Chain ID: 5042002
Currency: USDC
Explorer: https://testnet.arcscan.app

Get test USDC from Circle's faucet.
Why this matters
AI agents need to transact with each other. Right now there's no trustless primitive for agent-to-agent payments — agents borrow human wallets and hope for the best. ARC Escrow is the first step toward agents having their own economic identity: lock funds against a task hash, release on completion, dispute if something goes wrong.
Arc's USDC-native infrastructure makes this uniquely viable — no volatile gas token, no unpredictable fees, sub-second settlement.
Roadmap

Arbitration layer for disputed escrows
Agent identity and reputation scores
Multi-party escrow for complex agent workflows
Mainnet deployment when Arc launches

Built by @0xkhingx on Arc Testnet.
