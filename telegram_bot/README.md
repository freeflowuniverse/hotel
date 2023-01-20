Telegram Bot Specification

First Command: /start

/start, /help - display the help menu

Options:
- /help, /start
- /drinks
- /food
- /menu
- /rooms
- /boats
- /order
- /basket
- /confrim
- /ui
- anything else

/drinks - display the drinks menu
- get_drinks()

/food - display the food menu
- get_food()

/menu - display the food and drink menu
- get_drinks()
- get_food()

/rooms - display the rooms selection
- get_rooms()

/boats - display the boats selection
- get_boats() 

/order - add products to your basket
- create an order item with all specified products
- get_products() for the names of the products for confirmation message

/note - add a note to your basket for special requests

/basket - display the products in your basket
- get_products() to display basket contents

/confirm - confirm order and send to hotel, restaurant, dock
- log_purchase() - should contain username, product_ids, quantities and optional note

/ui - activate the ui version of the telegram bot
anything else - command not recognised, send '/help' for more info 

Necessary Endpoints:
- get_foods([]string) - empty list for all
- get_drinks([]string)
- get_boats([]string)
- get_rooms([]string)
- log_purchase(Order)



UI Process
- enter dock, bar, restaurant, hotel
  - view menu (prints menu and takes you to order)
  - order products (takes you to list of products)
    - list of products (requests a quantity response)
    - back (takes you back)
- view basket (takes you to the basket)
  - basket - remove items (takes you back to basket)
  - back 
- back (takes you back)

<!-- enum ProductType {
    none
    dock
    hotel
    food
    drink
}

pub struct State {
    basket       bool
    product_type ProductType
    product_id   string
} -->

States:
- bot menu (one)
  - product menu (dock, hotel, food, drink)
    - product list (dock, hotel, food, drink)
      - product purchase (one for every product)
  - basket (one)
    - product modification (one for every product in the basket)

bot_menu options:
- Dock Menu -> products_menu 
- Bar Menu -> products_menu
- Restaurant Menu -> products_menu
- Hotel Menu -> products_menu
- Basket -> basket
- Confirm Order

products_menu options (uniform for all product types):
- View menu
- Order items

basket options:
- product 1 -> product_modification
- product 2 -> product_modification
- product 3 -> product_modification
- ...

product_modification options (different for every product type):
- delete_project

food_modification options





Quantity definition per product:
- food/drinks - number of units
- rooms - number of nights
- boats - number of hours