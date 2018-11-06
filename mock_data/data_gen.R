## data_gen.R
## Creates and combines mock data


# CUSTOMER_T --------------------------------------------------------------

# Combine and output mock data from mockaroo (50,000 customers)
file_list <- paste0("supporting_data/customer_data_to_combine/",
                    list.files(path="supporting_data/customer_data_to_combine/."))
customer_t <- do.call(rbind, lapply(file_list, function(x) read.csv(x, stringsAsFactors = FALSE)))
write.csv(customer_t, "Customer_T.csv", row.names = FALSE)


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
glassesNames$product_description <- "Lorem ipsum sunglasses"
glassesNames$is_sunglass <- c(TRUE, FALSE, FALSE, TRUE, TRUE)
glassesNames$product_standard_price <- round(runif(300, 0, 2300), digits=2)
glassesNames$is_available <- c(TRUE, FALSE, TRUE, TRUE)
glassesNames$frame_type <- c("Cat Eye", "Aviator", "Rimless", "Oval", "Sport")
glassesNames$color <- colors$ColorName
glassesNames$photoURL <- c("https://imgur.com/a/fake1", "https://imgur.com/a/fake2")
colnames(glassesNames)[1] <- "ProductName"

write.csv(glassesNames, "Products_T.csv", row.names = FALSE)

# INVENTORY_T --------------------------------------------------------------
inventory <- as.data.frame(1:300)
inventory$quantity <- round(runif(300, 0, 2030), digits=0)
inventory$Products_T_ProductID <- 1:300
colnames(inventory)[1] <- "InventoryID"

write.csv(inventory, "Inventory_T", row.names = FALSE)

# ORDERLINE_T --------------------------------------------------------------
#TODO

# ORDER_T --------------------------------------------------------------
#OrderID, customerId, OrderDate, fullfillmentdate, ordercost

OrderDate <- sample(seq(as.Date('2017/01/01'), as.Date('2018/11/01'), by="day"),
                400000, replace = TRUE)
customerID <- sample(50000, 150000, replace = TRUE)
FullfillmentDate <- OrderDate + 1:10 # staggers fulfillment date from 1-10
OrderCost # TODO: Ordercost will be a sum of orderline data

# ORDERLINE_T --------------------------------------------------------------


# CUSTOMERCARTLINES_T --------------------------------------------------------------
#TODO
