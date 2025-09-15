# Check for duplicates
sum(duplicated(sales))

# Check for missing values
sum(is.na(sales))

# Check unique values
unique(sales$warehouse)
unique(sales$client_type)
unique(sales$product_line)
unique(sales$payment)

# Check range of values
ggplot(sales, aes(x = quantity)) +
  geom_histogram(binwidth = 10) 

ggplot(sales, aes(x = unit_price)) +
  geom_histogram(binwidth = 10) 

ggplot(sales, aes(x = total)) +
  geom_histogram(binwidth = 500) 

ggplot(sales, aes(x = payment_fee)) +
  geom_histogram(bins = 3) 
