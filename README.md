
## Flows
- Bar
- Kitchen

Overlap:
- flows
  - update_catalogue_flow
    - add_product
    - edit_product
  - read_catalogue_flow
  - order_flow
  - cancel_order_flow
    - for both guest and employees
  - update_stocks_flow
  - confirm_order_delivery_flow
- methods
  - get_state
  - get_stock
  - get_stocks
  - add_product
  - edit_product
  - order
  - cancel_order
  - update_stock
  - confirm_order_delivery


pub struct Vendor {
  products []ProductAmount
  orders []Order
  stock_updates []StockUpdate
}

what is uniform across all vendors








Components:
- UI Handlers 
- Supervisor Actors
  - CRUD data
  - spawn regular actors
- Regular Actors
  - Flows
    - use the ui lib to communicate with 
