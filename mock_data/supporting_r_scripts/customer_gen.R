## customer_gen.R
## AAMILLER
## Generates customer data
library(dplyr)

# Combine and output mock data from mockaroo (50,000 customers)
create_customer_t <- function() { 
  # Read in customer files
  file_list <- paste0("supporting_data/customer_data_to_combine/",
                      list.files(path="supporting_data/customer_data_to_combine/."))
  
  # Bind files together
  table <- do.call(rbind, lapply(file_list, function(x) read.csv(x, stringsAsFactors = FALSE)))
  
  # Add cities, using https://github.com/grammakov/USA-cities-and-states data
  city_data <- read.delim("supporting_r_scripts/supporting_data/us_cities_states_counties.csv",
                          stringsAsFactors = FALSE, sep="|")
  for (cust in 1:nrow(table)) {
    data_for_state <- city_data %>% filter(State.short == (table$state[[cust]])) %>% select(City)
    table$City[cust] <- sample(unique(data_for_state$City), 1)
    print(cust)
  }
  
  # Rename columns to match logical data model
  colnames(table) <- c("CustomerID", "CustomerName", "CustomerAddress",
                       "CustomerPostalCode", "CustomerState", "CustomerEmail", "CustomerCity")
  
  # Shift order of columns to match logical data mdoel
  table <- table[ , c("CustomerID", "CustomerName", "CustomerAddress", "CustomerCity", 
                      "CustomerState", "CustomerPostalCode", "CustomerEmail")]
  return(table) 
}
