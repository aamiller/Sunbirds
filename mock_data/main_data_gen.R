## main_data_gen.R
## AAMILLER 
## Creates and combines mock data
## Instructions for use: Run each table creation sequentially.
##                       If you change products, you'll need to re-run order-related table creation.
##                       Write lines are commented out to reduce the chance of accidental overwrite.

library(dplyr)

# SETUP --------------------------------------------------------------

# Date range to generate order data for
data_start_date <- as.Date('2015/01/01')
data_end_date <- as.Date('2018/12/31')

# Constants - do not change
customer_ct <- 50000

# CUSTOMER_T --------------------------------------------------------------
source('supporting_r_scripts/customer_gen.R')

# Returns 50,000 rows of fake customer data
customer_t <- create_customer_t()

#write.csv(customer_t, "./db_tables/Customer_T.csv", row.names = FALSE)

# FRAMETYPE_T --------------------------------------------------------------
source('supporting_r_scripts/frametype_gen.R')

frametype_t <- create_frametype_t()
#write.csv(frametype_t, "./db_tables/FrameType_T.csv", row.names = FALSE)

# PRODUCTS_T --------------------------------------------------------------
source('supporting_r_scripts/products_gen.R')

# Returns 300 rows of fake product data
products_t <- create_product_t()
products_t <- add_frame_type_id(frametype_t, products_t)

#write.csv(products_t, "./db_tables/Products_T.csv", row.names = FALSE)

# INVENTORY_T --------------------------------------------------------------
inventory <- as.data.frame(1:300)
inventory$quantity <- round(runif(300, 0, 2030), digits=0)
inventory$Products_T_ProductID <- 1:300
colnames(inventory)[1] <- "InventoryID"

#write.csv(inventory, "./db_tables/Inventory_T.csv", row.names = FALSE)

# CUSTOMERCARTLINES_T --------------------------------------------------------------
source('supporting_r_scripts/customercartlines_gen.R')
customercartlines_t <- create_customercartlines_t(customer_ct, products_t)

#write.csv(customercartlines_t, "./db_tables/Customercartlines_T.csv", row.names = FALSE)


# ORDERLINE_T & ORDER_T --------------------------------------------------------------
# Writes data to folders
write_OL_and_O_data()

# Read in final order table
order_t <- read.csv("order_dat/590000_slice_on_orders_600000.csv", stringsAsFactors = FALSE)
order_t <- order_t[c(1:600000), ]

#write.csv(order_t, "db_tables/Order_T.csv", row.names = FALSE)

# Read in order lines to combine, regex to match "orderlines" text in file name
ol_file_list <- paste0("order_dat/",
                    list.files(path="order_dat/.", pattern = "(.+)orderlines(.+)"))

# Bind files together
orderline_t <- do.call(rbind, lapply(ol_file_list, function(x) read.csv(x, stringsAsFactors = FALSE)))
orderline_t$OrderLineID <- 1:nrow(orderline_T)

#write.csv(orderline_t, "db_tables/Orderline_T.csv", row.names = FALSE)

# Handle holiday orders, adding trends artificially
source('holiday_dates_for_trends.R')

# Repeat dates across different times to mock orders at different
# times of the business being open, ex. 300 orders a day in a certain month
create_repeated_dates <- function(event_date, num_repetitions) {
  return(rep(seq(as.Date(event_date) - round(runif(1, 1, 7), 0), as.Date(event_date), by = "day"), num_repetitions))
}

repeat_holiday_dates <- function(dates_df) {
  output <- c(as.Date(create_repeated_dates(dates_df$`colnames(dates_df)`[1],
                                            dates_df$OM[1] * round(runif(1, 1, 400), 0))))
  QM <- rep(c(dates_df$QM[1]), length(output))
  for (i in 2:nrow(dates_df)) {
    new_dates <- c(as.Date(create_repeated_dates(dates_df$`colnames(dates_df)`[i],
                                              dates_df$OM[i] * round(runif(1, 1, 400), 0))))
    output <- c(output, new_dates)
    QM <- c(QM, rep(c(dates_df$QM[i]), length(new_dates)))
  }
  return(data.frame(output, QM, stringsAsFactors = FALSE))
}

holiday_dates <- repeat_holiday_dates(dates_df)

# Create dataframe to store order data -- wll need to adjust ID later
holiday_order <- data.frame(c(0), # Future order ID
                    holiday_dates$output,
                    holiday_dates$output + 1:6, # + 1:10 to add variation to fullfillment dates
                    c(0), c(0), holiday_dates$QM, stringsAsFactors = FALSE)
colnames(holiday_order) <- c("OrderID", "OrderDate", "FulfillmentDate", "OrderCost", "Customers_T_CustomerID", "qmultiplier")
holiday_order$Customers_T_CustomerID <- sample(1:nrow(customer_T), nrow(holiday_order), replace = TRUE)


# Create dataframe to store orderline data
create_orderline <- function() {
  orderline <- data.frame(c(0), c(0), c(0), c(0), stringsAsFactors = FALSE)
  colnames(orderline) <- c("OrderLineID", "OrderedQuantity", "Order_T_OrderID", "Products_T_ProductID")
  orderline <- orderline[c(-1), ]
  return(orderline)
}

orderline <- create_orderline()


# Modification on order_line_and_order_gen.R function to generate OLs
write_holiday_OL_and_O_data <- function() {
  # May run for a long time with large data sets
  for (i in 1:nrow(holiday_order)) {
    print(i)
    # For each order, pick 1-5 different items * QM (quantity multiplier for holiday) a customer might order.
    # We can ignore what is or isn't available currently, as it might have been 
    # available in the past and we aren't tracking historical availability data.
    item_ids_to_order <- sample(products_T$ProductID, (sample(1:5, 1)))
    items_to_order <- filter(products_T, ProductID %in% item_ids_to_order)
    
    # Handle quantities, multiply cost by quantity
    quantities <- sample(1:(1 + 5 * holiday_order$qmultiplier[i]), length(item_ids_to_order))
    items_to_order$ProductStandardPrice <- items_to_order$ProductStandardPrice * quantities
    
    # Sum the cost
    sum_cost <- sum(items_to_order$ProductStandardPrice)
    
    # Add cost to OrderID
    holiday_order$OrderCost[i] <- sum_cost
    
    # Add items to OrderLine
    for (p in 1:nrow(items_to_order)) {
      a <- data.frame(c(0), c(quantities[p]), c(i), c(items_to_order$ProductID[[p]]))
      names(a) <- colnames(orderline)
      orderline <- rbind(orderline, a)
    }
    
    # Write every 10000 rows  
    if (i %% 10000 == 0) {
      write.csv(holiday_order, paste0(i - 10000 ,"_slice_on_orders_", i, ".csv"), row.names = FALSE)
      write.csv(orderline, paste0(i - 10000, "_slice_on_orderlines_", i, ".csv"), row.names = FALSE)
      
      # Reset orderline for speed. Large orderline table slows process
      orderline <- create_orderline()
      print('write')
    }
  }
}

write_holiday_OL_and_O_data()


# Read in order lines to combine, regex to match "orderlines" text in file name
holiday_ol_file_list <- paste0("supporting_r_scripts/", list.files(path="supporting_r_scripts/.", pattern = "(.+)_slice_on_orderlines_(.+)"))

# Bind files together
holiday_orderline_t <- do.call(rbind, lapply(holiday_ol_file_list, function(x) read.csv(x, stringsAsFactors = FALSE)))

# Fix orderline numbers for holiday so they start at the end of the existing orderline ct
holiday_orderline_t$OrderLineID <- (nrow(orderline_T) + 1):(nrow(orderline_T) + nrow(holiday_orderline_t)) 

# Fix order numbers on orderline so they only apply to holiday order numbers
holiday_orderline_t$Order_T_OrderID <- holiday_orderline_t$Order_T_OrderID + nrow(order_T)

# Add holiday orderlines to orderline table
combined_orderlines <- rbind(orderline_T, holiday_orderline_t)

# Write new orderline table
# write.csv(combined_orderlines, "db_tables/Orderline_T.csv", row.names = FALSE)


# Read in holiday order table
holiday_order <- read.csv("supporting_r_scripts/120000_slice_on_orders_130000.csv", stringsAsFactors = FALSE)

# Remove qmultiplier column
holiday_order <- holiday_order[, c(-6)]

# Adjust order numbers
holiday_order$OrderID <- (nrow(order_T) + 1):(nrow(order_T) + nrow(holiday_order)) 
holiday_order <- holiday_order[1:130000, ]

# Combine and write
combined_orders <- rbind(order_T, holiday_order)

library(lubridate)

holiday_order$FulfillmentDate <- strptime(holiday_order$FulfillmentDate, "%m/%d/%y")
holiday_order$OrderDate<- strptime(holiday_order$OrderDate, "%m/%d/%y")

#write.csv(combined_orders, "db_tables/Order_T.csv", row.names = FALSE)




