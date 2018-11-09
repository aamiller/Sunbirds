## customercartlines_gen.R
## AAMILLER
## Generates cart lines using product and customer data
## order table

create_customercartlines_t <- function(customer_ct, products_t) {
  # Choose 2000 customers to have carts currently
  customer_ids_with_cart_lines <- as.data.frame(c(sample(500000, 2000)))
  
  # Initialize data frame
  customercartlines <- as.data.frame(c(''), stringsAsFactors = FALSE)
  customercartlines$customers_t_customerID <- 0
  
  # Add customers 1-5 times to mock them having between 1-5 things in their cart
  for (custid in customer_ids_with_cart_lines) {
    for (cartlinect in (1:round(runif(1, 1, 5)))) {
      a <- data.frame(c(''), custid)
      names(a) <- colnames(customercartlines)
      customercartlines <- rbind(customercartlines, a)
    }
  }
  
  # Filter down products to get IDs that are for products that are available
  availableGlasses <- products_t %>% filter(is_available == "TRUE") %>% select(ProductID)
  
  # Choose available IDs for cart lines
  customercartlines$products_t_productid <- sample(availableGlasses$ProductID,
                                                   nrow(customercartlines), replace = TRUE)
  
  # Set quantities randomly between 1-5
  customercartlines$quantity <- sample(5, nrow(customercartlines), replace = TRUE)
  
  # Ad cartline ID
  customercartlines <- customercartlines[c(-1), ]
  customercartlines$CartLineID <- 1:nrow(customercartlines)
  
  # Format data
  colnames(customercartlines) <- c("Customers_T_CustomerID", "Products_T_ProductID", "Quantity", "CartLineID")
  customercartlines <- customercartlines[ c(-1), c("CartLineID", "Customers_T_CustomerID", "Products_T_ProductID", "Quantity")]
  
  return(customercartlines)
}
