# 🌊 OceanChain Initiative

A comprehensive blockchain-based platform for marine conservation, ocean cleanup projects, marine biodiversity tracking, and sustainable ocean resource management with community-driven verification and funding systems.

## ✨ Features

### 🌊 Marine Conservation Projects
- **Project Creation**: Launch ocean cleanup and conservation initiatives with detailed descriptions
- **Cleanup Tracking**: Record waste collection and environmental restoration measurements
- **Funding System**: Community-driven funding with transparent allocation and rewards
- **Progress Monitoring**: Track project completion against environmental targets

### 🐠 Marine Biodiversity Management
- **Species Registration**: Document marine species populations and conservation status
- **Population Tracking**: Monitor species population changes over time
- **Habitat Mapping**: Record critical habitat locations and ecosystem health
- **Conservation Status Updates**: Track endangered species recovery progress

### 🔍 Verification & Validation
- **Community Verification**: Distributed verification system for project authenticity
- **Impact Confirmation**: Validate cleanup measurements and conservation outcomes
- **Reputation System**: Build trust through successful project delivery and verification
- **Verification Notes**: Detailed feedback from marine conservation validators

### 🪙 Ocean Token Economy
- **Reward System**: Earn Ocean Tokens for conservation activities and project funding
- **Token Transfer**: Peer-to-peer Ocean Token exchange system
- **Impact Scoring**: Accumulate impact scores based on conservation contributions
- **Funding Incentives**: Token rewards for supporting marine conservation projects

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- Basic understanding of Clarity smart contract language

### Installation
1. Clone this repository
2. Navigate to the project directory
3. Run `clarinet check` to verify the contract

### Usage Examples

#### Register as a User
```bash
clarinet call oceanchain register-user u3
```
- `u3`: Verification level (determines voting power in validation)

#### Create a Marine Conservation Project
```bash
clarinet call oceanchain create-conservation-project "Pacific Cleanup Initiative" "ocean-cleanup" "North Pacific Gyre" "Large-scale plastic removal from the Pacific Ocean using innovative collection systems" u50000 u100000
```
- `"Pacific Cleanup Initiative"`: Project name
- `"ocean-cleanup"`: Project type (ocean-cleanup, reef-restoration, species-protection)
- `"North Pacific Gyre"`: Location
- `"Large-scale plastic removal..."`: Project description
- `u50000`: Target cleanup amount (kg of waste)
- `u100000`: Funding goal (micro-STX)

#### Record Cleanup Measurement
```bash
clarinet call oceanchain record-cleanup-measurement u1 "plastic-debris" u2500 "35.6821N, 139.7670E"
```
- `u1`: Project ID
- `"plastic-debris"`: Type of waste collected
- `u2500`: Amount collected (kg)
- `"35.6821N, 139.7670E"`: GPS coordinates

#### Verify a Conservation Project
```bash
clarinet call oceanchain verify-project u1 u2500 "Verified cleanup of 2.5 tons of plastic debris through satellite imagery and field inspection"
```
- `u1`: Project ID to verify
- `u2500`: Confirmed cleanup amount (kg)
- `"Verified cleanup of 2.5 tons..."`: Verification notes

#### Fund a Conservation Project
```bash
clarinet call oceanchain fund-project u1 u25000
```
- `u1`: Project ID to fund
- `u25000`: Funding amount (micro-STX)

#### Register Marine Species
```bash
clarinet call oceanchain register-marine-species "Pacific Sea Turtle" u1500 "vulnerable" "Monterey Bay, California"
```
- `"Pacific Sea Turtle"`: Species name
- `u1500`: Current population count
- `"vulnerable"`: Conservation status (critically-endangered, endangered, vulnerable, stable)
- `"Monterey Bay, California"`: Habitat location

#### Transfer Ocean Tokens
```bash
clarinet call oceanchain transfer-ocean-tokens 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE u250
```
- Recipient principal address
- `u250`: Number of Ocean Tokens to transfer

#### Complete a Project
```bash
clarinet call oceanchain complete-project u1
```
- `u1`: Project ID (requires target cleanup to be met)

## 📋 Smart Contract Functions

### Public Functions
- `register-user(verification-level)` - Register as platform participant with verification rights
- `create-conservation-project(name, project-type, location, description, target-cleanup, funding-goal)` - Create new marine conservation project
- `record-cleanup-measurement(project-id, waste-type, amount-collected, location-data)` - Log cleanup measurements
- `verify-project(project-id, cleanup-confirmed, verification-notes)` - Verify project impact claims
- `fund-project(project-id, amount)` - Provide funding for conservation projects
- `register-marine-species(species-name, population-count, conservation-status, habitat-location)` - Document marine species
- `transfer-ocean-tokens(recipient, amount)` - Send Ocean Tokens to another user
- `complete-project(project-id)` - Mark project as completed and claim completion bonus
- `update-species-population(species-id, new-population)` - Update species population data
- `update-platform-fee(new-rate)` - Adjust platform fee structure (admin only)
- `withdraw-conservation-fund(amount, recipient)` - Withdraw from conservation fund (admin only)

### Read-Only Functions
- `get-user-data(user)` - Retrieve user profile and statistics
- `get-project-data(project-id)` - Get complete project information
- `get-measurement-data(measurement-id)` - Access cleanup measurement details
- `get-species-data(species-id)` - View marine species information
- `get-transaction-data(transaction-id)` - Check transaction history
- `get-project-verification(project-id, verifier)` - View verification status
- `get-project-funding(project-id, funder)` - Check funding details
- `get-platform-stats()` - Platform-wide metrics and statistics
- `calculate-project-progress(project-id)` - Project completion percentage
- `get-user-token-balance(user)` - Individual Ocean Token balance

## 🏗️ System Architecture

### Data Structures
- **Users**: Ocean Token balances, project creation history, verification levels, reputation
- **Conservation Projects**: Creator, location, cleanup targets, funding status, verification state
- **Verifications**: Validator consensus, impact confirmation, detailed verification notes
- **Cleanup Measurements**: Waste type, collection amounts, GPS coordinates, verification status
- **Marine Species**: Population data, conservation status, habitat locations, update history
- **Transactions**: Complete history of token transfers, funding, and project activities
- **Project Funding**: Individual funding contributions with reward calculations

### Economic Model
- **Platform Fee**: 3% fee on project funding supports conservation operations
- **Funding Rewards**: Contributors earn 1.5x Ocean Tokens for project funding
- **Verification Incentives**: Reputation rewards for accurate project verification
- **Completion Bonuses**: Project creators earn bonus tokens for successful completion
- **Conservation Fund**: Platform fees accumulate for ecosystem-wide conservation efforts

## 🛡️ Security Features

- **Ownership Validation**: Only project creators can record measurements and complete projects
- **Verification Authority**: Verification rights based on user verification level
- **Balance Verification**: Prevents token transfers exceeding available balance
- **Duplicate Prevention**: Users cannot verify the same project multiple times
- **Admin Controls**: Platform parameters restricted to contract owner
- **Input Validation**: Comprehensive checks on all user inputs and data

## 🌍 Environmental Impact

### Supported Project Types
- **Ocean Cleanup**: Plastic debris removal, ghost net recovery, beach cleanups
- **Reef Restoration**: Coral reef rehabilitation and protection programs
- **Species Protection**: Marine wildlife conservation and habitat restoration
- **Pollution Prevention**: Industrial waste reduction and sustainable practices
- **Research & Monitoring**: Marine ecosystem health studies and data collection
- **Education & Outreach**: Community awareness and marine conservation education

### Measurement Categories
- **Waste Collection**: Plastic debris, microplastics, fishing nets (by weight)
- **Habitat Restoration**: Coral coverage, seagrass beds, mangrove areas (by area)
- **Species Recovery**: Population counts, breeding success rates, habitat quality
- **Water Quality**: pH levels, oxygen content, pollution indicators
- **Carbon Sequestration**: Blue carbon storage in marine ecosystems

## 📈 Platform Metrics

The contract tracks comprehensive marine conservation metrics:
- Total ocean area cleaned and waste removed
- Number of active conservation projects by type
- Marine species population tracking and conservation status
- Conservation fund allocation and platform fee rates
- User participation and community verification statistics
- Project success rates and environmental impact achievements

## 🤝 Contributing

This smart contract provides the foundation for transparent marine conservation tracking and community-driven ocean protection. Contributions welcome for:
- Integration with marine research institutions and data sources
- Enhanced species tracking and biodiversity monitoring systems
- Satellite imagery integration for cleanup verification
- Mobile applications for field data collection
- Partnership with existing marine conservation organizations
- Advanced analytics and impact measurement tools

## 📄 License

Open source - ready for community development and deployment on the Stacks blockchain.

---

**🌊 Protecting our oceans through transparent, community-driven conservation! 🐠**
