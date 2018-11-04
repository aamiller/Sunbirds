## data_gen.R
## Creates and combines mock data

# Combine and output mock data from mockaroo (50,000 customers)
file_list <- paste0("supporting_data/customer_data_to_combine/", list.files(path="supporting_data/customer_data_to_combine/."))
customer_t <- do.call(rbind, lapply(file_list, function(x) read.csv(x, stringsAsFactors = FALSE)))
write.csv(customer_t, "Customer_T.csv", row.names = FALSE)


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
glassesNames <- as.data.frame(paste(colors$ColorName, nouns$nouns, "Glasses"), stringsAsFactors = FALSE)

# Choose 300 product names, write them
# TODO -- currently only contains product names
write.csv(glassesNames[sample(nrow(glassesNames), 300), ], "Products_T.csv", row.names = FALSE)


