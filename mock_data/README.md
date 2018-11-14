# Mock Data for Database

Mocked data by Adele using `data_gen.R`.

## Customer_T
### 50,000 Customers

Created by combining [Mockaroo](https://www.mockaroo.com/) data with specific customer fields.

Fields
- "CustomerID" - Primary key, not necessary because it will be autoincremented
- "CustomerName" - Combined first and last name
- "CustomerAddress" - Street address
- "CustomerCity" - City in given state
- "CustomerState" - 2 letter state code
- "CustomerPostalCode" - Zip/postal code
- "CustomerEmail" Standard format email

Example: 4,"Raye Tuiller","69668 Kennedy Park", "La Mesa", 92415,"CA","rtuiller3@who.int"

## Product_T
### 300 Products
Created by combining color names and nouns, and recycling vectors to fill out fields with booleans or other strings.
Colors are from [this repository](https://github.com/codebrainz/color-names).
Nouns are from the R [lexicon package](https://cran.r-project.org/web/packages/lexicon/lexicon.pdf).

Fields
- "ProductID"
- "ProductName" - Color + Noun + "Glasses"
- "ProductDescription" - All "Lorem ipsum sunglasses"
- "is_sunglass" - True or false, if not a sunglass, normal glasses
- "ProductStandardPrice" - Price of product
- "is_available" - Whether or not product is available for purchase, regardless of quantity in inventory
- "FrameType_T_FrameTypeID" - FK to color and shape details
- "photoURL" - One of two fake photourls

Example: "China Rose Squid Glasses","Lorem ipsum sunglasses",TRUE,706.87,FALSE,2,"https://imgur.com/a/fake2"

## Inventory_T
### 300 Inventory lines
Created by using numbers 1-300 inclusive, representing the ids for products, and inputting a random quantity of the product.
A product can have a non-zero quantity even if it is not available, not available products just can't go in carts.

Fields
- "InventoryID" - PK for row in table
- "Quantity" - Quantity of item on hand
- "Products_T_ProductID" - Foreign key to product

Example: 1,1880,1 
(stimulating, I know.)

## Customercartlines_T
# Thousands of records

Created using a random sampling of customer IDs, where one customer ID can appear multiple times because they may have multiple things in their cart. Each orderline has a product ID associated with it and a quantity for the item in the cart.

Fields
- "CartLineID"
- "Customers_T_CustomerID" - A customer ID
- "Products_T_ProductID" - A product ID
- "Quantity" - A quantity between 1 and 5

Example: 37421, 21, 4

## Orderline_T
# Records ~ 600,000 * 3
Individual order lines from orders.
- "OrderLineID"
- "OrderedQuantity" - Quantity of item ordered
- "Order_T_OrderID" - FK to linked order
- "Product_T_ProductID" - product ordered

## Order_T
# Records 600,000
- "OrderID"
- "OrderDate" - date order was places
- "FullfillmentDate" - date order was fulfilled
- "OrderCost" - total cost of order, based on orderlines
- "Customers_T_CustomerID" - Id of ordering customer
