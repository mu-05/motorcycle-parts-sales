# Exploratory Analysis - Revenue growth

# Get month number using strftime() function
query <- "
  SELECT order_number,
         date,
         strftime('%m',date) AS month_chr,
         CAST(strftime('%m',date) AS INT) AS month_int,
         CASE CAST(strftime('%m',date) AS INT) 
                WHEN 6 THEN 'June'
                WHEN 7 THEN 'July'
                WHEN 8 THEN 'August'
         END AS month_chr_full
    FROM sales
   ORDER BY RANDOM()
   LIMIT 10;
"
DBI::dbGetQuery(con, query)

# Calculate net total for each transaction
query <- "
  SELECT order_number,
         total,
         payment_fee,
         total - ROUND(total * payment_fee, 2) AS net_total
    FROM sales
   ORDER BY RANDOM()
   LIMIT 10;
"
DBI::dbGetQuery(con, query)

# Draft temporary table query
query <- "
  SELECT warehouse,
         date,
         CAST(strftime('%m',date) AS INT) AS month_int,
         CASE strftime('%m',date)
                WHEN '06' THEN 'June'
                WHEN '07' THEN 'July'
                WHEN '08' THEN 'August'
         END AS month_chr,
         total,
         payment_fee,
         total - ROUND(total * payment_fee, 2) AS net_total
    FROM sales
   WHERE client_type = 'Wholesale'
   ORDER BY RANDOM()
   LIMIT 10;
"
DBI::dbGetQuery(con, query)

# Create final query to calculate monthly revenue for each warehouse
query <- "
  -- Step 1: Create a temporary table of wholesale sales
  -- Adds month information and calculates net total (after payment fee)
  WITH sales_wholesale_revenue AS(
    SELECT warehouse,
           date,
           CAST(strftime('%m',date) AS INT) AS month_int,
           CASE strftime('%m',date)
                  WHEN '06' THEN 'June'
                  WHEN '07' THEN 'July'
                  WHEN '08' THEN 'August'
           END AS month_chr,
           total,
           payment_fee,
           total - ROUND(total * payment_fee, 2) AS net_total
      FROM sales
     WHERE client_type = 'Wholesale'
  )
  
  -- Step 2: Summarize net revenue by warehouse and month
  SELECT warehouse,
         month_chr,
         SUM(net_total) AS net_revenue
    FROM sales_wholesale_revenue
   GROUP BY warehouse, month_int, month_chr
   ORDER BY warehouse, month_int;
"

DBI::dbGetQuery(con, query)

# Calculate monthly revenue with R
sales_monthly_revenue <- sales %>%
  filter(client_type == "Wholesale") %>%
  mutate(
    month_int = month(x = date),
    month_chr = month(x = date, label = TRUE, abbr = FALSE),
    net_total = total - round(total * payment_fee, 2)
  ) %>%
  group_by(warehouse, month_int, month_chr) %>%
  summarize(net_revenue = sum(net_total)) %>%
  ungroup()

sales_monthly_revenue

# Format data
sales_monthly_revenue_formatted <- sales_monthly_revenue %>%
  select(-month_int) %>%
  mutate(
    net_revenue = scales::dollar(net_revenue, accuracy = 1), 
    month_chr = as.character(month_chr)
  )

sales_monthly_revenue_formatted

# Plot monthly net revenue by warehouse
monthly_sales_plot <- ggplot(sales_monthly_revenue, aes(x = month_chr, y = net_revenue, group = warehouse)) +
  geom_line(aes(color = warehouse), linewidth = 2) +
  labs(
    title = "Net Revenue Trends Across Warehouses",
    x = "Month",
    y = "Net Revenue",
    color = "Warehouse"
  ) +
  scale_y_continuous(label = scales::label_dollar()) 

monthly_sales_plot

# Average monthly net revenue for each warehouse
sales_monthly_avg <- sales_monthly_revenue %>%
  group_by(warehouse) %>%
  summarize(
    avg_monthly_net_revenue = round(mean(net_revenue) / 100) * 100
    )
  
sales_monthly_avg

# Calculate revenue growth rate for each warehouse
sales_monthly_revenue %>%
  select(-month_int) %>%
  group_by(warehouse) %>%
  mutate(
    net_revenue_lag = lag(net_revenue),
    growth_rate = (net_revenue - net_revenue_lag) / net_revenue_lag,
    growth_rate_label = scales::percent(growth_rate)
  ) 

# Plot proportion of customers by warehouse
ggplot(sales, aes(x = warehouse, group = client_type)) +
  geom_bar(aes(fill = client_type), position = "fill") +
  labs(
    title= "Proportion of Customers by Warehouse",
    x = "Warehouse",
    y = "Proportion",
    fill = "Client Type"
  ) + 
  scale_y_continuous(labels = scales::percent_format())

# Revenue share split by client type for each warehouse
sales_total_proportion <- sales %>%
  group_by(warehouse, client_type) %>%
  summarize(total_order = sum(total)) %>%
  mutate(rate_total = total_order/sum(total_order) * 100) %>%
  ungroup()

sales_total_proportion

# Plot revenue share split by client type for each warehouse
ggplot(sales_total_proportion, aes(x = warehouse, y = rate_total, group = client_type)) +
  geom_col(aes(fill = client_type), position = "fill") +
  labs(
    title= "Revenue Share split by Client Type for each Warehouse",
    x = "Warehouse",
    y = "Proportion",
    fill = "Client Type"
  ) + 
  scale_y_continuous(labels = scales::percent_format())
