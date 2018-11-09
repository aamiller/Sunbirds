# frametype_gen.R
# Generates frame type combinations
library(lexicon)
library(dplyr)

create_frametype_t <- function() {
  # Read in colors
  colors <- read.csv("supporting_r_scripts/supporting_data/colors.csv", stringsAsFactors = FALSE)
  colnames(colors)[2] <- "ColorName"
  colors <- as.data.frame(colors[!grepl('\\(', colors$ColorName), ])
  
  # Frame types
  frame_shapes <- c("Cat Eye", "Aviator", "Rimless", "Oval", "Sport")
  
  # Create all possible combinations
  frame_t <- data.frame(c(''), c(''), c(''), stringsAsFactors = FALSE)
  colnames(frame_t) <- c("FrameTypeID", "FrameColorDescription", "FrameShapeDescription")
  frame_t <- frame_t[c(-1), ]
  
  for (color in colors$ColorName) {
    for (frameshape in frame_shapes) {
      df <- data.frame(1, color, frameshape)
      names(df) <- colnames(frame_t)
      frame_t <- rbind(frame_t, df)
    }
  }
  
  # add IDs
  frame_t$FrameTypeID <- 1:nrow(frame_t)
  
  return(frame_t)
}

# Adds frame type, removes other frametype-related cols
add_frame_type_id <- function(frametype_t, products_t) {
  for (curr_row in 1:nrow(products_t)) {
    curr_color <- products_t$color[curr_row]
    curr_shape <- products_t$frame_type[curr_row]
    frame_type_id <- frametype_t %>% filter(FrameColorDescription == curr_color, 
                                            FrameShapeDescription == curr_shape)
    products_t$FrameType_T_FrameTypeID[[curr_row]] <- frame_type_id$FrameTypeID[1]
  }
  
  # Organize rows
  products_t <- products_t[, c("id", "ProductName", "product_description",
                               "is_sunglass", "product_standard_price", 
                               "is_available", "photoURL", "FrameType_T_FrameTypeID")]
  colnames(products_t) <- c("ProductID", "ProductName", "ProductDescription",
                            "is_sunglass", "ProductStandardPrice", "is_available",
                            "photoURL", "FrameType_T_FrameTypeID")
  products_t
}