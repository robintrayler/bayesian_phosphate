library(tidyverse)
library(colorspace)
library(ggridges)
theme_set(theme_minimal())
source('./R/model_water_temperature.R')
# load the captive shark data -------------------------------------------------
data <- read_csv(file = './data/data.csv') %>%
  filter(thermo == 'Ecto') 

# create a list to store the results 

# set MCMC parameters 
iterations = 50000
burn = 5000

temp_range  <- c(10, 40)
d18Ow_range <- c(data$d18Ow_min[1], data$d18Ow_max[1])

results <- model_water_temperature(
  d18Op = data$d18Op,
  d18Op_sd = 0.2,
  temperature_prior_param = temp_range, # uniform range
  temperature_prior_type = 'uniform',
  water_prior_param = d18Ow_range, # mean and sd
  water_prior_type = 'uniform',
  iterations = iterations, 
  sigma_prior_param = 1,
  burn = burn,
  equation = 'kolodny') %>% 
  add_column(group = 'ecto_ungrouped')


# collapse back into a data frame

write_csv(x = results, file = './data/ecto_ungrouped_posterior.csv')
