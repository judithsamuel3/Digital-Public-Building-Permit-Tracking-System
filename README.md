# Digital Public Building Permit Tracking System

A comprehensive blockchain-based system for managing construction permits, inspections, and compliance using Clarity smart contracts on the Stacks blockchain.

## System Overview

This system consists of five interconnected smart contracts that handle the complete lifecycle of building permits:

### 1. Application Processing Contract (`application-processing.clar`)
- Manages construction permit requests and reviews
- Handles application submissions, status tracking, and review workflows
- Stores applicant information and project details

### 2. Fee Calculation Contract (`fee-calculation.clar`)
- Determines permit costs based on project scope and type
- Calculates fees for different construction categories
- Manages fee payment tracking and receipts

### 3. Inspection Scheduling Contract (`inspection-scheduling.clar`)
- Coordinates required building inspections
- Manages inspector assignments and scheduling
- Tracks inspection results and compliance status

### 4. Approval Notification Contract (`approval-notification.clar`)
- Sends permit approvals and construction authorization
- Manages notification workflows and status updates
- Handles permit issuance and documentation

### 5. Violation Enforcement Contract (`violation-enforcement.clar`)
- Manages stop-work orders and compliance issues
- Tracks violations and enforcement actions
- Handles penalty assessments and resolution

## Features

- **Transparent Process**: All permit activities recorded on blockchain
- **Automated Workflows**: Smart contract automation reduces processing time
- **Fee Management**: Automated fee calculation and payment tracking
- **Inspection Coordination**: Streamlined inspection scheduling and results
- **Compliance Tracking**: Real-time violation monitoring and enforcement
- **Audit Trail**: Complete history of all permit-related activities

## Contract Architecture

Each contract operates independently while maintaining data consistency:

- **Application Processing**: Core permit lifecycle management
- **Fee Calculation**: Financial aspects and payment processing
- **Inspection Scheduling**: Quality assurance and compliance verification
- **Approval Notification**: Communication and authorization
- **Violation Enforcement**: Compliance monitoring and penalties

## Data Types

### Permit Application
- Application ID (uint)
- Applicant principal
- Project type and description
- Property address
- Estimated cost
- Application timestamp
- Current status

### Fee Structure
- Base fees by permit type
- Multipliers for project size/complexity
- Payment status and timestamps
- Receipt generation

### Inspection Records
- Inspection type and requirements
- Scheduled dates and assigned inspectors
- Results and compliance status
- Follow-up requirements

### Approval Records
- Approval status and timestamps
- Authorized construction activities
- Permit validity periods
- Conditions and restrictions

### Violation Records
- Violation type and severity
- Discovery date and reporting party
- Enforcement actions taken
- Resolution status and penalties

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for deployment

### Installation
\`\`\`bash
git clone <repository-url>
cd building-permit-system
npm install
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy
\`\`\`

## Usage Examples

### Submit Permit Application
\`\`\`clarity
(contract-call? .application-processing submit-application
"Residential Addition"
"123 Main St"
u50000)
\`\`\`

### Calculate Permit Fee
\`\`\`clarity
(contract-call? .fee-calculation calculate-fee
"residential"
u50000)
\`\`\`

### Schedule Inspection
\`\`\`clarity
(contract-call? .inspection-scheduling schedule-inspection
u1
"foundation"
u1640995200)
\`\`\`

## Error Codes

- `ERR-NOT-AUTHORIZED` (u100): Caller not authorized for action
- `ERR-INVALID-INPUT` (u101): Invalid input parameters
- `ERR-NOT-FOUND` (u102): Record not found
- `ERR-ALREADY-EXISTS` (u103): Record already exists
- `ERR-INVALID-STATUS` (u104): Invalid status for operation
- `ERR-INSUFFICIENT-PAYMENT` (u105): Payment amount insufficient
- `ERR-EXPIRED` (u106): Permit or deadline expired

## Security Considerations

- Only authorized personnel can approve permits
- Fee payments must be verified before approval
- Inspection results are immutable once recorded
- Violation enforcement requires proper authorization
- All sensitive operations include access controls

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details
