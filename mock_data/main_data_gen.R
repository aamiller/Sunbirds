## data_gen.R
## AAMILLER 
## Creates and combines mock data
## Instructions for use: Run each table creation sequentially.
##                       If you change products, you'll need to re-run order-related table creation.
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

