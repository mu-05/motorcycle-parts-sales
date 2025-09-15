# Exploratory Analysis - Net revenue

# Calculate net total for each transaction
query <- "
  SELECT order_number, 
         total - ROUND(total * payment_fee, 2) AS net_total
    FROM sales
  LIMIT 10;
"
DBI::dbGetQuery(con, query)

# Calculate net revenue and revenue share for each client type
query <- "
  SELECT client_type, 
         SUM(total - ROUND(total * payment_fee, 2)) AS net_revenue,
         SUM(total - ROUND(total * payment_fee, 2)) / (
            SELECT SUM(total - ROUND(total * payment_fee, 2))
              FROM sales
            ) AS revenue_share
    FROM sales 
   GROUP BY client_type;
"
DBI::dbGetQuery(con, query)

# Calculate net revenue an revenue share with R
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

# Format the data
sales_summary_formatted <- sales_summary %>%
  mutate(
    net_revenue = scales::dollar(net_revenue, accuracy = 1),
    revenue_share = scales::percent(revenue_share, accuracy = 0.1)
  )

sales_summary_formatted

# Plot net revenue by client type
ggplot(sales_summary, aes(x = client_type, y = net_revenue)) +
  geom_col() +
  ggtitle(label = "Net Revenue by Client Type") +
  xlab(label = "Type of Client") +
  ylab(label = "Net Revenue") + 
  scale_y_continuous(
    labels = scales::dollar_format()
  )

# Calculate sales means
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
avg_quantity_plot <- ggplot(sales_means, aes(x = client_type, y = mean_quantity)) +
  geom_col() +
  labs(
    title= "Average Quantity Ordered\nby Client Type",
    x = "Type of Client",
    y = "Average Quantity Ordered"
  )

# Plot mean total by client type
avg_total_plot <- ggplot(sales_means, aes(x = client_type, y = mean_total)) +
  geom_col() +
  labs(
    title= "Average Order Amount\nby Client Type",
    x = "Type of Client",
    y = "Average Order Amount"
  ) + 
  scale_y_continuous(
    labels = scales::dollar_format()
  )

# Arrange the plots side by side 
gridExtra::grid.arrange(avg_quantity_plot, avg_total_plot, ncol = 2)
