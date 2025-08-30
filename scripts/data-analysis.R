# Load libraries
library(tidyverse)
library(DBI)
library(RSQLite)

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
DBI::dbGetQuery(con, "SELECT strftime('%m', date) FROM sales")

# Close the connection
dbDisconnect(con)