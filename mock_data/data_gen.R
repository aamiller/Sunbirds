## data_gen.R
## Creates and combines mock data

# Combine mock data from mockaroo (50,000 customers)
file_list <- paste0("customer_data_to_combine/", list.files(path="customer_data_to_combine/."))
customer_t <- do.call(rbind, lapply(file_list, function(x) read.csv(x, stringsAsFactors = FALSE)))

write.csv(customer_t, "Customer_T.csv")