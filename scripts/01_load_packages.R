# Load packages
library(DBI)
library(RSQLite)
library(tidyverse)
library(scales)

# Set default theme for plots
theme_set(theme_bw(base_size = 16))

# Check number of digits to display
?options
getOption(x = "digits")