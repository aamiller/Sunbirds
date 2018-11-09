## products_gen.R
## AAMILLER
## Generates product data

# Generate product names using a dictionary and appending 
# the word "Sunglasses" to the end of each product name
library(stringr)
library(lexicon)

create_product_t <- function() {
  data(pos_df_irregular_nouns)
  nouns <- as.data.frame(str_to_title(pos_df_irregular_nouns$singular), stringsAsFactors = FALSE)
  nouns <- as.data.frame(nouns[-c(123, 112, 76, 74, 75, 71, 60, 41, 38, 8), ]) # remove some
  colnames(nouns) <- "nouns"
  
  # Read in colors, clean
  colors <- read.csv("supporting_r_scripts/supporting_data/colors.csv", stringsAsFactors = FALSE)
  colnames(colors)[2] <- "ColorName"
  colors <- colors[!grepl('\\(', colors$ColorName), ]
  colors <- colors[sample(nrow(colors), 300), ]
  
  glassesNames <- as.data.frame(paste(colors$ColorName, nouns[sample(nrow(nouns), 300, replace=TRUE),
                                                              'nouns'], "Glasses"), stringsAsFactors = FALSE)
  
  # Choose other factors
  glassesNames$id <- 1:300
  glassesNames$product_description <- "Lorem ipsum sunglasses"
  glassesNames$is_sunglass <- c(TRUE, FALSE, FALSE, TRUE, TRUE)
  glassesNames$product_standard_price <- round(runif(300, 0, 2300), digits=2)
  glassesNames$is_available <- c(TRUE, FALSE, TRUE, TRUE)
  glassesNames$frame_type <- c("Cat Eye", "Aviator", "Rimless", "Oval", "Sport")
  glassesNames$color <- colors$ColorName
  glassesNames$photoURL <- c("https://imgur.com/a/fake1", "https://imgur.com/a/fake2")
  colnames(glassesNames)[1] <- "ProductName"
  
  return(glassesNames)
}