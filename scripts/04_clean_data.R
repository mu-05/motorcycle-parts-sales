# Convert date column from POSIXct to character
class(sales$date)
sales$date <- as.Date(x = sales$date)
sales$date <- format(sales$date, "%Y-%m-%d")

# Check new data type
class(sales$date)