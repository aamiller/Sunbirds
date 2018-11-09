## customer_gen.R
## AAMILLER
## Generates customer data
library(dplyr)
source('main_data_gen.R') # For start and end dates

# Mock 365 * 700+ orders
# Repeat dates across different times to mock orders at different
# times of the business being open, ex. 300 orders a day in a certain month
create_repeated_dates <- function(start_date, end_date, num_repetitions) {
  return(rep(seq(as.Date(start_date), as.Date(end_date), by = "day"), num_repetitions))
}

# Date ranges, number of orders each day
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

write_OL_and_O_data <- function() {
  # May run for a long time with large data sets
  for (i in 1:nrow(order)) {
    # For each order, pick 1-5 different items a customer might order.
    # We can ignore what is or isn't available currently, as it might have been 
    # available in the past and we aren't tracking historical availability data.
    item_ids_to_order <- sample(products_t$ProductID, sample(1:5, 1))
    items_to_order <- filter(products_t, ProductID %in% item_ids_to_order)
    
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
    
    # Write every 20000 rows  
    if (i %% 10000 == 0) {
      write.csv(order, paste0("order_dat/", i - 10000 ,"_slice_on_orders_", i, ".csv"), row.names = FALSE)
      write.csv(orderline, paste0("order_dat/", i - 10000, "_slice_on_orderlines_", i, ".csv"), row.names = FALSE)
      
      # Reset orderline for speed. Large orderline table slows process
      orderline <- create_orderline()
    }
  }
}