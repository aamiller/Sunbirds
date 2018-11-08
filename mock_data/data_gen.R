## data_gen.R
## Creates and combines mock data
library(dplyr)

data_start_date <- as.Date('2015/01/01')
data_end_date <- as.Date('2018/12/31')
customer_ct <- 50000

# CUSTOMER_T --------------------------------------------------------------

# Combine and output mock data from mockaroo (50,000 customers)
file_list <- paste0("supporting_data/customer_data_to_combine/",
                    list.files(path="supporting_data/customer_data_to_combine/."))
customer_t <- do.call(rbind, lapply(file_list, function(x) read.csv(x, stringsAsFactors = FALSE)))
#write.csv(customer_t, "Customer_T.csv", row.names = FALSE)


# PRODUCTS_T --------------------------------------------------------------

# Generate product names using a dictionary and appending 
# the word "Sunglasses" to the end of each product name
library(stringr)
library(lexicon)

data(pos_df_irregular_nouns)
nouns <- as.data.frame(str_to_title(pos_df_irregular_nouns$singular), stringsAsFactors = FALSE)
nouns <- as.data.frame(nouns[-c(123, 112, 76, 74, 75, 71, 60, 41, 38, 8), ]) # remove some
colnames(nouns) <- "nouns"

# Read in colors, clean
colors <- read.csv("supporting_data/colors.csv", stringsAsFactors = FALSE)
colnames(colors)[2] <- "ColorName"
colors <- colors[!grepl('\\(', colors$ColorName), ]
colors <- colors[sample(nrow(colors), 300), ]

glassesNames <- as.data.frame(paste(colors$ColorName, nouns[sample(nrow(nouns), 300, replace=TRUE),
                                                            'nouns'], "Glasses"), stringsAsFactors = FALSE)

# Choose other factors
glassesNames$id <- 1:300
glassesNames$product_description <- "Lorem ipsum sunglasses"
glassesNames$is_sunglass <- c(TRUE, FALSE, FALSE, TRUE, TRUE)
glassesNames$product_standard_price <- round(runif(300, 0, 2300), digits=2)
glassesNames$is_available <- c(TRUE, FALSE, TRUE, TRUE)
glassesNames$frame_type <- c("Cat Eye", "Aviator", "Rimless", "Oval", "Sport")
glassesNames$color <- colors$ColorName
glassesNames$photoURL <- c("https://imgur.com/a/fake1", "https://imgur.com/a/fake2")
colnames(glassesNames)[1] <- "ProductName"
#write.csv(glassesNames, "Products_T.csv", row.names = FALSE)

# INVENTORY_T --------------------------------------------------------------
inventory <- as.data.frame(1:300)
inventory$quantity <- round(runif(300, 0, 2030), digits=0)
inventory$Products_T_ProductID <- 1:300
colnames(inventory)[1] <- "InventoryID"

#write.csv(inventory, "Inventory_T.csv", row.names = FALSE)

# CUSTOMERCARTLINES_T --------------------------------------------------------------
# Choose 2000 customers to have carts currently
customer_ids_with_cart_lines <- as.data.frame(c(sample(customer_ct, 2000)))

# Initialize data frame
customercartlines <- as.data.frame(c(''), stringsAsFactors = FALSE)
customercartlines$customers_t_customerID <- 0

# Add customers 1-5 times
for (custid in customer_ids_with_cart_lines) {
  for (cartlinect in (1:round(runif(1, 1, 5)))) {
    a <- data.frame(c(''), custid)
    names(a) <- colnames(customercartlines)
    customercartlines <- rbind(customercartlines, a)
  }
}

# Filter down glassesNames to get IDS that are for products that are available
availableGlasses <- glassesNames %>% filter(is_available == "TRUE") %>% select(id)

customercartlines$products_t_productid <- sample(availableGlasses$id,
                                                 nrow(customercartlines), replace = TRUE)
customercartlines$quantity <- sample(5, nrow(customercartlines), replace = TRUE)

#write.csv(customercartlines[c(-1), c(-1)], "Customercartlines_T.csv", row.names = FALSE)


# ORDERLINE_T & ORDER_T --------------------------------------------------------------
# Mock 365 * 700+ orders
# Repeat dates across different times to mock orders at different
# times of the business being open, ex. 300 orders a day in a certain month
create_repeated_dates <- function(start_date, end_date, num_repetitions) {
  return(rep(seq(as.Date(start_date), as.Date(end_date), by = "day"), num_repetitions))
}

order_dates <- c(   
  # 2015
  create_repeated_dates('2015/01/01', '2015/07/01', 60),
  create_repeated_dates('2015/07/02', '2015/12/31', 100),
  # 2016
  create_repeated_dates('2016/01/01', '2016/07/01', 150),
  create_repeated_dates('2016/07/02', '2016/12/31', 250),
  # 2017
  create_repeated_dates('2017/01/01', '2017/07/01', 400),
  create_repeated_dates('2017/07/02', '2017/12/31', 600),
  # 2018
  create_repeated_dates('2018/01/01', '2018/07/01', 700),
  create_repeated_dates('2018/07/02', '2018/12/31', 1050)
)

# Create dataframe to store order data
order <- data.frame(c(0), # Future order ID
                    order_dates,
                    order_dates + 1:10, # + 1:10 to add variation to fullfillment dates
                    c(0), c(0), stringsAsFactors = FALSE)
colnames(order) <- c("OrderID", "OrderDate", "FulfillmentDate", "OrderCost", "Customers_T_CustomerID")
order$OrderID <- 1:nrow(order)
order$Customers_T_CustomerID <- sample(1:customer_ct, nrow(order), replace = TRUE)

# Create dataframe to store orderline data
create_orderline <- function() {
  orderline <- data.frame(c(0), c(0), c(0), c(0), stringsAsFactors = FALSE)
  colnames(orderline) <- c("OrderLineID", "OrderedQuantity", "Order_T_OrderID", "Products_T_ProductID")
  orderline <- orderline[c(-1), ]
  return(orderline)
}
orderline <- create_orderline()
  
# Runs for a long time
for (i in 490001:nrow(order)) {
# For each order, pick 1-5 different items a customer might order.
# We can ignore what is or isn't available currently, as it might have been 
# available in the past and we aren't tracking historical availability data.
item_ids_to_order <- sample(glassesNames$id, sample(1:5, 1))
items_to_order <- filter(glassesNames, id %in% item_ids_to_order)

# Handle quantities, multiply cost by quantity
quantities <- sample(1:5, length(item_ids_to_order))
items_to_order$product_standard_price <- items_to_order$product_standard_price * quantities

# Sum the cost
sum_cost <- sum(items_to_order$product_standard_price)

# Add cost to OrderID
order$OrderCost[i] <- sum_cost

  # Add items to OrderLine
  for (p in 1:nrow(items_to_order)) {
    a <- data.frame(c(0), c(quantities[p]), c(i), c(items_to_order$id[[p]]))
    names(a) <- colnames(orderline)
    orderline <- rbind(orderline, a)
  }

  print(i)
  # Write every 20000 rows  
  if (i %% 10000 == 0) {
    print("write")
    write.csv(order, paste0("order_dat/", i - 10000 ,"_slice_on_orders_", i, ".csv"), row.names = FALSE)
    write.csv(orderline, paste0("order_dat/", i - 10000, "_slice_on_orderlines_", i, ".csv"), row.names = FALSE)
    
    # Reset orderline for speed. Large orderline table slows process
    orderline <- create_orderline()
  }
}

#write.csv(orderline, "last_orderline_rows.csv", row.names = FALSE)
#write.csv(order, "Order_T.csv", row.names = FALSE)

#TODO
# Handle holiday orders
source('holiday_dates_for_trends.R')

