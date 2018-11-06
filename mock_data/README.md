# Mock Data for Database

Mocked data by Adele using `data_gen.R`.

## Customer_T
### 50,000 Customers

Created by combining [Mockaroo](https://www.mockaroo.com/) data with specific customer fields.

Fields
- "id"      - Primary key, not necessary because it will be autoincremented
- "name"    - Combined first and last name
- "address" - Street address
- "zipcode" - Zip/postal code
- "state"   - 2 letter state code
- "email"   - Standard format email

Example: 4,"Raye Tuiller","69668 Kennedy Park",92415,"CA","rtuiller3@who.int"

## Product_T
### 300 Products
Created by combining color names and nouns, and recycling vectors to fill out fields with booleans or other strings.
Colors are from [this repository](https://github.com/codebrainz/color-names).
Nouns are from the R [lexicon package](https://cran.r-project.org/web/packages/lexicon/lexicon.pdf).

Fields
- "id"
- "ProductName" - Color + Noun + "Glasses"
- "product_description" - All "Lorem ipsum sunglasses"
- "is_sunglass" - True or false, if not a sunglass, normal glasses
- "product_standard_price" - Price of product
- "is_available" - Whether or not product is available for purchase
- "frame_type" - Cat Eye, Aviator, Rimless, Oval, or Sport
- "color" - The same color associated with ProductName
- "photoURL" - One of two fake photourls

Example: "China Rose Squid Glasses","Lorem ipsum sunglasses",TRUE,706.87,FALSE,"Sport","China Rose","https://imgur.com/a/fake2"

## Inventory_T
### 300 Inventory lines
Created by using numbers 1-300 inclusive, representing the ids for products, and inputting a random quantity of the product.
A product can have a non-zero quantity even if it is not available, not available products just can't go in carts.

Fields
- "InventoryID" - PK for row in table
- "quantity" - Quantity of item on hand
- "Products_T_ProductID" - Foreign key to product

Example: 1,1880,1 
(stimulating, I know.)

## Customercartlines_T

Created using a random sampling of customer IDs, where one customer ID can appear multiple times because they may have multiple things in their cart. Each orderline has a product ID associated with it and a quantity for the item in the cart.

Fields
- "customers_t_customerID" - A customer ID
- "products_t_productid" - A product ID
- "quantity" - A quantity between 1 and 5

Example: 37421, 21, 4

## Orderline_T

## Order_T
