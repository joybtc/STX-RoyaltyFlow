# STX-RoyaltyFlow Music Royalty Distribution Smart Contract

A smart contract for fair and transparent royalty distribution among artists, producers, and rights holders, built on the Stacks blockchain using Clarity.

---

## 📌 Overview

This smart contract is designed to manage the registration of songs and automatically distribute royalty payments based on predefined percentages. It allows contract administrators to manage the ecosystem while ensuring that revenue is transparently and fairly shared among contributors.

---

## ✅ Key Features

- **Song Registration** with metadata (title, primary artist, publication block).
- **Royalty Distribution** logic with support for multiple recipients per song.
- **Automatic Payment Distribution** based on royalty percentages.
- **Participant Role Definition** to differentiate between artists, producers, etc.
- **Administrator Access Control** for critical functions.
- **Status Management** for enabling/disabling songs.
- **Administrator Transfer** support.

---

## 📦 Data Structures

### 1. `RegisteredSongs`

Tracks all registered songs.

```clarity
{
  song-identifier: uint,
  song-title: (string-ascii 50),
  primary-artist: principal,
  accumulated-revenue: uint,
  publication-date: uint,
  song-status-active: bool
}
```

### 2. `RoyaltyDistribution`

Tracks revenue share distribution per participant per song.

```clarity
{
  song-identifier: uint,
  royalty-recipient: principal,
  royalty-percentage: uint,
  participant-role: (string-ascii 20),
  accumulated-earnings: uint
}
```

---

## 🚦 Error Codes

| Code | Meaning |
|------|---------|
| 100 | Unauthorized access |
| 101 | Invalid royalty percentage |
| 102 | Duplicate song entry |
| 103 | Song does not exist |
| 104 | Insufficient payment funds |
| 105 | Invalid royalty recipient |
| 106 | Payment failed |
| 107 | Invalid string length |
| 108 | Invalid song title |
| 109 | Invalid participant role |
| 110 | Invalid primary artist |
| 111 | Invalid administrator |

---

## ⚙️ Functions

### 🔍 Read-Only

- `get-song-information(song-identifier)`
- `get-royalty-distribution(song-identifier, recipient)`
- `get-total-registered-songs()`
- `get-royalty-shares-by-song(song-identifier)`

### 🔒 Private

- `is-valid-royalty-share(share)`
- `verify-contract-administrator()`
- `validate-royalty-percentage(%)`
- `validate-string-ascii(input)`
- `validate-participant-role(role)`
- `validate-principal(principal)`
- `process-royalty-share(share, amount)`
- `distribute-royalty-payment(song-id, amount)`

### 📤 Public

- `register-new-song(title, primary-artist)`
- `set-royalty-distribution(song-id, recipient, %, role)`
- `process-royalty-payment(song-id, amount)`
- `update-song-active-status(song-id, status)`
- `transfer-administrator-rights(new-admin)`

---

## 🔐 Access Control

- Only the `contract-administrator` can:
  - Register new songs.
  - Update song active status.
  - Transfer administrator rights.

---

## 💰 Royalty Payment Flow

1. A song is registered with a unique ID.
2. Royalty shares are defined for contributors (e.g., artist 50%, producer 30%, label 20%).
3. A royalty payment is made via `process-royalty-payment`.
4. Funds are automatically transferred to each recipient based on their share.

---

## 🚧 Input Validations

- Royalty percentage must be between 0–100.
- Song title and role strings must be within length limits.
- Royalty recipient must not be the sender or admin.
- Must be a valid song and active.

---

## 🛡️ Security Measures

- Prevents unauthorized access.
- Validates all input lengths and types.
- Prevents duplicate or invalid royalty assignments.
- Ensures atomic royalty distribution or rolls back if failed.

---

## 🏁 Initialization

```clarity
(begin
  (var-set registered-song-count u0)
)
```

Ensures clean state with zero registered songs at deployment.

---

## Deployment Notes

- Deploy on the Stacks testnet or mainnet using Clarinet or Hiro IDE.
- Ensure initial administrator (deployer) is a secure and trustworthy entity.

---

##  License

MIT License — Free to use, adapt, and distribute with credit.
