# Create SQLite connection
con <- dbConnect(
  drv = RSQLite::SQLite(), 
  dbname = ":memory:")

# Write the sales data frame to the database
dbWriteTable(
  conn = con,
  name = "sales",
  value = sales
)

# Check the data using R code
DBI::dbGetQuery(con, "SELECT * FROM sales LIMIT 10;")

# Check column details
DBI::dbGetQuery(con, "PRAGMA table_info(sales)")

