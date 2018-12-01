## read_in_tables.R
## Quick way to read all tables into memory
path <- "../db_tables/"

customer_T <- read.csv(paste0(path, "Customer_T.csv"))

customercartlines_T <- read.csv(paste0(path, "Customercartlines_T.csv"))

frameType_T <- read.csv(paste0(path, "FrameType_T.csv"))

inventory_T <- read.csv(paste0(path, "Inventory_T.csv"))

order_T <- read.csv(paste0(path, "Order_T.csv"))

orderline_T <- read.csv(paste0(path, "Orderline_T.csv"))

products_T <- read.csv(paste0(path, "Products_T.csv"))
