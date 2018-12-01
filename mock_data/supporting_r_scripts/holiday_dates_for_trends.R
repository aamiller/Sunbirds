## holiday_dates_for_trends.R
## For tracking holiday trend data
library(tidyr)
library(dplyr)

# Dates to help interject trends into the data
christmas_dates <-         c('2015/12/25', '2016/12/25', '2017/12/25', '2018/12/25')
valentines_dates <-        c('2015/02/14', '2016/02/14', '2017/02/14', '2018/02/14')
halloween_dates <-         c('2015/10/31', '2016/10/31', '2017/10/31', '2018/10/31')
labor_dates <-             c('2015/09/07', '2016/09/05', '2017/09/04', '2018/09/03')
mothers_day <-             c('2015/05/10', '2016/05/08', '2017/05/14', '2018/05/13')
fathers_day <-             c('2015/06/21', '2016/06/19', '2017/06/18', '2018/06/17')
national_sunglasses_day <- c('2015/07/27', '2016/07/27', '2017/07/27', '2018/07/27')

# Combine dates
dates_df <- data.frame(christmas_dates, valentines_dates, halloween_dates, 
                       labor_dates, mothers_day, fathers_day, national_sunglasses_day)
dates_df <- dates_df %>% gather(colnames(dates_df), key = "datetype")

# First value from 1.5-5 changes the multiplier of orders placed (OM - order multiplier)
# Second value 1.5-5 changes the quantity of products in each order (QM - quantity multiplier)
# Ex. Christmas: 5x as many orders, 3x as many products per order
# Logic: Some holidays have a lot of orders with a lot of products in them.
#        We have gotten more popular over time. `year_popularity_multiplier` changes
#        our popularity factor over time.
year_popularity_multiplier <- c(1.0, 1.2, 1.4, 3)

christmas_dates_OM <-  5 * year_popularity_multiplier
christmas_dates_QM <-  3 * year_popularity_multiplier

valentines_dates_OM <- 2 * year_popularity_multiplier
valentines_dates_QM <- 1 * year_popularity_multiplier

halloween_dates_OM <-  1.5 * year_popularity_multiplier
halloween_dates_QM <-  1.5 * year_popularity_multiplier

labor_dates_OM <-      3 * year_popularity_multiplier
labor_dates_QM <-      3.5 * year_popularity_multiplier

mothers_day_OM <-      1.5 * year_popularity_multiplier
mothers_day_QM <-      2 * year_popularity_multiplier

fathers_day_OM <-      1.5 * year_popularity_multiplier
fathers_day_QM <-      2.2 * year_popularity_multiplier

national_sunglasses_day_OM <- 5 * year_popularity_multiplier
national_sunglasses_day_QM <- 3.5 * year_popularity_multiplier

# Combine order multipliers
OM_multiplier_df <- data.frame(christmas_dates_OM, valentines_dates_OM, halloween_dates_OM, 
                       labor_dates_OM, mothers_day_OM, fathers_day_OM, national_sunglasses_day_OM)
OM_multiplier_df <- OM_multiplier_df %>% gather(colnames(OM_multiplier_df), key = "OM")


# Combine quantity multipliers
QM_multiplier_df <- data.frame(christmas_dates_QM, valentines_dates_QM, halloween_dates_QM, 
                               labor_dates_QM, mothers_day_QM, fathers_day_QM, national_sunglasses_day_QM)
QM_multiplier_df <- QM_multiplier_df %>% gather(colnames(QM_multiplier_df), key = "OM")

dates_df$OM <- OM_multiplier_df$`colnames(OM_multiplier_df)`
dates_df$QM <- QM_multiplier_df$`colnames(QM_multiplier_df)`