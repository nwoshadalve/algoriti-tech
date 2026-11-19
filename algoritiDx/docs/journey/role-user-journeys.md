# Branch role user journeys

**Status: Proposed workflows for discussion.** These diagrams cover the eight branch roles, their handoffs, and common exceptions. They are not finalized operating procedures or an exhaustive permission specification.

All users sign in, select an assigned branch, and see only permitted actions. One employee may hold several roles. Actions and approvals are recorded against individual accounts.

## Overall patient journey

```mermaid
flowchart TD
    A[Patient arrives] --> B[Reception: identify or register patient]
    B --> C[Create test or examination order]
    C --> D[Cashier: record payment or authorized credit]
    D --> E{Service type}
    E -->|Laboratory| F[Collect and label samples]
    F --> G[Receive and process samples]
    G --> H[Enter results]
    E -->|Imaging| I[Schedule and perform examination]
    I --> J[Prepare findings]
    H --> K[Authorized reviewer reviews report]
    J --> K
    K --> L{Approved?}
    L -->|No| M[Return for correction or further work]
    M --> K
    L -->|Yes| N[Approved report available]
    N --> O[Verify recipient and delivery eligibility]
    O --> P[Deliver report and record handover]
```

Payment eligibility, clinical authorization, and report release rules must be configurable and agreed. An order may contain several services that progress independently; collection, examination, and report readiness are tracked per item.

## 1. Branch manager

```mermaid
flowchart TD
    A[Open branch overview] --> B[Review workload and pending exceptions]
    B --> C{Work area}
    C -->|Staff| D[Assign permitted staff and responsibilities]
    C -->|Operations| E[Review delayed orders, samples, and reports]
    E --> F[Assign follow-up to responsible role]
    C -->|Financial approval| G[Review discount, refund, or cancellation request]
    G --> H{Within authority?}
    H -->|No| I[Escalate to authorized organization approver]
    H -->|Yes| J{Approve?}
    J -->|Yes| K[Record approval and reason]
    J -->|No| L[Record rejection and reason]
    K --> M[Cashier or reception executes permitted action]
    C -->|Collections| N[Review payment totals and reconciliation]
    N --> O{Discrepancy?}
    O -->|Yes| P[Investigate with cashier and record resolution]
    O -->|No| Q[Record review or closing approval]
    P --> Q
    D --> R[Monitor outcome]
    F --> R
    I --> R
    L --> R
    M --> R
    Q --> R
```

Management authority does not grant clinical report approval. Financial limits and closing procedures remain to be defined.

## 2. Receptionist

```mermaid
flowchart TD
    A[Patient requests services] --> B[Search existing patient records]
    B --> C{Identity matched?}
    C -->|Yes| D[Verify and confirm patient details]
    C -->|No| E[Register patient after duplicate check]
    D --> F[Select tests or examinations]
    E --> F
    F --> G[Confirm branch, service availability, prices, and instructions]
    G --> H{Special approval or clarification needed?}
    H -->|Yes| I[Refer to authorized staff and resolve]
    I --> G
    H -->|No| J[Create order and any required appointment]
    J --> K[Hand off to cashier]
    K --> L[Give order reference and next-step instructions]
    L --> M{Later change requested?}
    M -->|No| N[Track order status when needed]
    M -->|Yes| O[Check service progress and change permissions]
    O --> P{Change allowed?}
    P -->|Yes| Q[Record amendment and notify affected staff]
    P -->|Approval required| R[Request authorized approval]
    P -->|No| S[Explain restriction and escalate if needed]
```

Do not silently replace patient identity or completed order items. Paid changes may require cashier adjustments; cancellations may require approval.

## 3. Cashier

```mermaid
flowchart TD
    A[Open patient order] --> B[Verify patient, charges, and outstanding balance]
    B --> C{Discount, credit, or refund requested?}
    C -->|Yes| D[Check authority or obtain approval]
    D --> E{Approved?}
    E -->|No| B
    E -->|Yes| F[Record authorized adjustment]
    C -->|No| G[Receive payment]
    F --> G
    G --> H{Payment confirmed?}
    H -->|No| I[Record unresolved or failed attempt without marking paid]
    I --> G
    H -->|Yes| J[Post payment and issue receipt]
    J --> K[Update paid, partial, or due balance]
    K --> L[Make payment status available to service staff]
    L --> M{Later refund or correction?}
    M -->|Yes| N[Verify approval and record linked refund or reversal]
    M -->|No| O[Reconcile collections at shift end]
    N --> O
    O --> P{Totals match?}
    P -->|No| Q[Record discrepancy and escalate]
    P -->|Yes| R[Submit closing summary]
    Q --> R
```

Refunds and reversals preserve the original transaction history. Permitted partial-payment and credit policies remain open.

## 4. Sample collector

```mermaid
flowchart TD
    A[Open collection worklist] --> B[Verify patient and ordered sample requirements]
    B --> C{Identity, preparation, and service eligibility confirmed?}
    C -->|No| D[Pause and refer issue to responsible staff]
    D --> B
    C -->|Yes| E[Collect sample and label at collection]
    E --> F[Record collector, time, sample identity, and exceptions]
    F --> G{Collection successful?}
    G -->|No| H[Record reason and arrange follow-up or recollection]
    H --> B
    G -->|Yes| I[Prepare handover to lab or authorized transfer]
    I --> J[Record handover and receiving destination]
    J --> K{Lab accepts sample?}
    K -->|Yes| L[Collection handoff complete]
    K -->|No| M[Receive rejection reason and coordinate recollection]
    M --> B
```

Sample verification and rejection rules must be agreed with authorized clinical/laboratory personnel. Cross-branch transfers require a separately defined tracking workflow.

## 5. Lab technologist

```mermaid
flowchart TD
    A[Receive sample] --> B[Verify label, order, and sample suitability]
    B --> C{Acceptable?}
    C -->|No| D[Record rejection reason and notify collection staff]
    C -->|Yes| E[Record receipt and begin permitted processing]
    E --> F{Processing or quality issue?}
    F -->|Yes| G[Record issue and refer for authorized resolution]
    G --> H{Repeat or recollect?}
    H -->|Repeat permitted| E
    H -->|Recollect| D
    H -->|Hold| I[Keep item pending with reason]
    F -->|No| J[Enter results with applicable units and reference information]
    J --> K[Check completeness and flag findings requiring escalation]
    K --> L[Follow approved urgent-notification procedure when applicable]
    L --> M[Submit draft report for authorized review]
    M --> N{Returned for correction?}
    N -->|Yes| O[Resolve comments with recorded changes]
    O --> K
    N -->|No| P[Track review outcome]
```

Technologist result entry does not automatically grant final approval. Quality control, urgent findings, and repeat-test procedures require clinical definition.

## 6. Reporting doctor / authorized reviewer

```mermaid
flowchart TD
    A[Open reports awaiting review] --> B[Select report within authorized scope]
    B --> C[Verify patient, examination, findings, and supporting information]
    C --> D{Sufficient and acceptable?}
    D -->|No| E[Return with comments or request further work]
    E --> F[Receive revised findings]
    F --> C
    D -->|Yes| G[Review urgent findings and required communication]
    G --> H[Approve report and record reviewer and time]
    H --> I[Release approved version to permitted delivery workflow]
    I --> J{Correction needed after approval?}
    J -->|No| K[Review complete]
    J -->|Yes| L[Initiate controlled amendment with reason]
    L --> M[Review and approve amended version]
    M --> N[Preserve prior version and notify affected recipients as required]
```

Approval is limited by professional authorization and report type, not management status. Signature, release, amendment, and urgent-notification rules remain to be agreed.

## 7. Imaging staff

```mermaid
flowchart TD
    A[Open imaging orders and appointments] --> B[Confirm service, patient, and schedule]
    B --> C{Appointment change needed?}
    C -->|Yes| D[Reschedule and notify relevant staff or patient]
    D --> B
    C -->|No| E[Verify patient and required readiness checks]
    E --> F{Ready to proceed?}
    F -->|No| G[Record hold, no-show, or cancellation reason]
    G --> H[Coordinate next action with authorized staff]
    F -->|Yes| I[Perform examination within authorized duties]
    I --> J{Examination completed?}
    J -->|No| K[Record issue and arrange authorized next step]
    J -->|Yes| L[Record completion and attach permitted supporting material]
    L --> M[Prepare findings where authorized]
    M --> N[Submit to authorized reporting professional]
    N --> O{Further work requested?}
    O -->|Yes| P[Resolve request within assigned duties]
    P --> N
    O -->|No| Q[Track reporting status]
```

Imaging staff is a role group; scheduling, performing an examination, drafting findings, and approving a report may belong to different people and permissions.

## 8. Report delivery staff

```mermaid
flowchart TD
    A[Patient or representative requests report] --> B[Find order and verify patient and recipient authority]
    B --> C{Approved report available?}
    C -->|No| D[Explain pending status and follow up with responsible staff]
    C -->|Yes| E[Check applicable delivery and payment policy]
    E --> F{Delivery permitted?}
    F -->|No| G[Refer payment or authorization issue to responsible staff]
    G --> E
    F -->|Yes| H[Confirm correct patient, service, and latest approved version]
    H --> I[Print or deliver through an authorized channel]
    I --> J{Delivery successful?}
    J -->|No| K[Record failure and arrange retry]
    K --> I
    J -->|Yes| L[Record recipient, channel, time, and delivered version]
    L --> M{Later reprint or amended report?}
    M -->|Yes| N[Reverify recipient and latest approved version]
    N --> E
    M -->|No| O[Delivery complete]
```

Delivery staff cannot edit clinical findings or approve reports. Recipient verification, digital delivery consent, and release conditions remain to be defined.

## Common rules across journeys

- Clinical authorization, financial approval, and branch access are separate permissions.
- Combining roles must not bypass required approvals.
- Holds, cancellations, reversals, and amendments preserve history and record reasons.
- In Online-only, actions run through the cloud. In Online + Offline, branch actions save locally first; synchronization follows connectivity and cloud entitlement.
- Pending synchronization must be distinguishable from completed local work. Do not ask staff to recreate an order or payment merely because synchronization is delayed.
- Cloud-based requests for local branch transactions follow the proposed ownership and confirmation rules in the architecture document; these are not yet finalized.

## Discussion still needed

Detailed journeys for cross-branch referrals and sample transfers, outsourced services, home collection, inventory, organization-level users, and platform administrators are outside these branch-role diagrams. We must also agree on order/item states, partial completion and delivery, identity corrections, approval limits, report authorization, and downtime recovery.

[Branch roles](branch-roles.md) · [High-level architecture](../architecture/high-level.md)
