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

write.csv(inventory, "Inventory_T.csv", row.names = FALSE)

# CUSTOMERCARTLINES_T --------------------------------------------------------------
# Choose 2000 customers to have carts currently
customer_ids_with_cart_lines <- as.data.frame(c(sample(50000, 2000)))

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

customercartlines$products_t_productid <- sample(50000, nrow(customercartlines), replace = FALSE)
customercartlines$quantity <- sample(5, nrow(customercartlines), replace = TRUE)

write.csv(customercartlines[c(-1), c(-1)], "Customercartlines_T.csv", row.names = FALSE)


# ORDERLINE_T --------------------------------------------------------------
# Dates to help interject trends into the data
christmas_dates <-         c('2015/12/25', '2016/12/25', '2017/12/25', '2018/12/25')
valentines_dates <-        c('2015/02/14', '2016/02/14', '2017/02/14', '2018/02/14')
halloween_dates <-         c('2015/10/31', '2016/10/31', '2017/10/31', '2018/10/31')
labor_dates <-             c('2015/09/07', '2016/09/05', '2017/09/04', '2018/09/03')
mothers_day <-             c('2015/05/10', '2016/05/08', '2017/05/14', '2018/05/13')
fathers_day <-             c('2015/06/21', '2016/06/19', '2017/06/18', '2018/06/17')
national_sunglasses_day <- c('2015/07/27', '2016/07/27', '2017/07/27', '2018/07/27')

dates_df <- data.frame(christmas_dates, valentines_dates, 
                          halloween_dates, labor_dates, mothers_day,
                          fathers_day, national_sunglasses_day)
library(tidyr)
dates_df <- dates_df %>% gather(colnames(dates_df), key = "datetype")


# ORDER_T --------------------------------------------------------------
#OrderID, customerId, OrderDate, fullfillmentdate, ordercost

OrderDate <- sample(seq(as.Date('2015/01/01'), as.Date('2018/12/31'), by="day"),
                    400000, replace = TRUE)
customerID <- sample(50000, 150000, replace = TRUE)
FullfillmentDate <- OrderDate + 1:10 # staggers fulfillment date from 1-10


OrderCost # TODO: Ordercost will be a sum of orderline data

# ORDERLINE_T --------------------------------------------------------------
## Need to interject trends
