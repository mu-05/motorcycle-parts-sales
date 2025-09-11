# Load libraries
library(tidyverse)
library(DBI)
library(RSQLite)
library(scales)

# Get working directory
getwd()

# Load data
sales <- read_csv(file = "data/sales.csv")

# Glimpse
glimpse(sales)

# Convert date column from POSIXct to character 
sales$date <- as.Date(x = sales$date)
sales$date <- format(sales$date, "%Y-%m-%d")
class(sales$date)

# Create SQLite connection
con <- dbConnect(
  drv = RSQLite::SQLite(), 
  dbname = ":memory:")

# Write the data frame to the database
dbWriteTable(
  conn = con,
  name = "sales",
  value = sales
)

# See the data using R code
DBI::dbGetQuery(con, "SELECT * FROM sales LIMIT 10;")

# See column details
DBI::dbGetQuery(con, "PRAGMA table_info(sales)")

# Get month number using strftime() function
DBI::dbGetQuery(con, "SELECT strftime('%m', date) FROM sales ORDER BY RANDOM() LIMIT 10;")

# Calculate net revenue
DBI::dbGetQuery(con, "SELECT order_number, ROUND(total - (total * payment_fee), 2) AS net_revenue FROM sales LIMIT 10;")

# Calculate net revenue by client type
query <- "
  SELECT client_type, 
         SUM(total - ROUND(total * payment_fee, 2)) AS net_revenue,
         SUM(total - ROUND(total * payment_fee, 2)) / 
            (
              SELECT SUM(total - ROUND(total * payment_fee, 2))
                FROM sales
            ) AS percent
    FROM sales 
   GROUP BY client_type;
"
DBI::dbGetQuery(con, query)

# ... with R
sales_summary <- sales %>% 
  group_by(client_type) %>%
  summarize(
    net_revenue = sum(total) - sum(total * payment_fee)
  ) %>%
  ungroup() %>%
  mutate(
    revenue_share = net_revenue / sum(net_revenue)
  )

sales_summary

sales_summary_formatted <- sales_summary %>%
  mutate(
    net_revenue_label = scales::dollar(net_revenue),
    revenue_share_label = scales::percent(revenue_share, accuracy = 0.1)
  ) %>%
  select(client_type, net_revenue_label, revenue_share_label)

sales_summary_formatted

# Set default theme
theme_set(theme_bw(base_size = 14)) 

# Plot net revenue by client type
ggplot(sales_summary, aes(x = client_type, y = net_revenue)) +
  geom_col() +
  ggtitle(label = "Net Revenue by Client Type") +
  xlab(label = "Type of Client") +
  ylab(label = "Net Revenue") + 
  scale_y_continuous(
    labels = scales::dollar_format()
  )

# Set number of digits
?options
getOption(x = "digits")

glimpse(sales)

# Get sales means
sales_means <- sales %>%
  group_by(client_type) %>%
  summarize(
    mean_quantity = mean(quantity),
    mean_total = mean(total)
  ) %>%
  ungroup() %>%
  mutate(
    mean_quantity = round(mean_quantity)
  )

# Plot mean quantity by client type
plot1 <- ggplot(sales_means, aes(x = client_type, y = mean_quantity)) +
  geom_col() +
  labs(
    title= "Average Quantity Ordered by Client Type",
    x = "Type of Client",
    y = "Average Quantity Ordered"
  )

# Plot mean total by client type
plot2 <- ggplot(sales_means, aes(x = client_type, y = mean_total)) +
  geom_col() +
  labs(
    title= "Average Order Amount by Client Type",
    x = "Type of Client",
    y = "Average Order Amount"
  ) + 
  scale_y_continuous(
    labels = scales::dollar_format()
  )

# Plot 
gridExtra::grid.arrange(plot1, plot2)

# Histogram of quantity sold
ggplot(sales, aes(x = quantity)) +
  geom_histogram(bins = 5) +
  facet_wrap(vars(client_type))

# Close the connection
dbDisconnect(con)
