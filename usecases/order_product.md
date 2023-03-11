## USE CASE 1: GUEST ORDER PRODUCT

### A. CHARACTERISTIC INFORMATION
- **Goal in context**: Guest orders a product and is delivered that product.
- **Scope**: System
- **Level**: Primary Task
- **Preconditions**: The guest must be registered with the hotel and the product must be available.
- **Success end condition**: The guest receives the product and we record the balance due.
- **Failed end condition**: The guest does not receive the product, we failed to record the balance due.
- **Primary user**: Guest
- **Trigger**: The guest sends a purchase request through one of the interfaces.
  
### B. MAIN SUCCESS SCENARIO
1. Guest specifies a product along with delivery time, quantity and other details.
2. System records the order details as well as change to guest balance.
3. System sends order to appropriate vendor.
4. Vendor completes order and logs it as complete.
5. Order is delivered to guest.

### C. EXTENSIONS
1a. Vendor does not have sufficient quantity of a certain product: System alerts guest and order is cancelled.
1b. The guest decides to cancel their order: Guest alerts system (Use Case 2: GUEST CANCEL ORDER) and order is cancelled.
2a. Guest balance is too far in deficit: System alerts guest and order is cancelled.
3a. Vendor is unable to fulfil order: Vendor cancels order (Use Case 3: VENDOR CANCEL ORDER).

### D. VARIATIONS

### E. RELATED INFORMATION
- **Priority**: Top
- **Performance target**: 5 minutes for order, delivery variable based on product and vendor.
- **Frequency**: 300/day 
- **Superordinate use case**: 
- **Subordinate use case**: GUEST CANCEL ORDER(2), VENDOR CANCEL ORDER(3)
- **Channel to primary user**: Telegram, web interface, other bots.
- **Secondary users**: Vendors
- **Channel to secondary users**: Telegram, web interface, other bots.

### F. SCHEDULE
- **Due date**: Release 1.0

### G. OPEN ISSUES
- 
