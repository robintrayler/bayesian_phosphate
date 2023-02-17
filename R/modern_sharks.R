library(tidyverse)
library(colorspace)
library(ggridges)
theme_set(theme_minimal())
source('./R/model_water_temperature.R')
# load the captive shark data -------------------------------------------------
data <- read_csv(file = './data/modern_aquarium_sharks.csv')

# create a list to store the results 

# set MCMC parameters 
iterations = 50000
burn = 5000

temp_range  <- c(10, 40)
d18Ow_range <- c(0, 0.5)

results <- model_water_temperature(
  d18Op = data$d18Op,
  d18Op_sd = 0.3,
  temperature_prior_param = temp_range, # uniform range
  temperature_prior_type = 'uniform',
  water_prior_param = d18Ow_range, # mean and sd
  water_prior_type = 'normal',
  iterations = iterations, 
  sigma_prior_param = 1,
  burn = burn,
  equation = 'kolodny') %>% 
  add_column(group = 'modern_sharks')

# collapse back into a data frame

write_csv(x = results, file = './data/aquarium_sharks.csv')

results |> 
  summarise(temperature_mean = mean(temperature),
            temperature_sd = sd(temperature),
            d18O_mean = mean(d18Ow),
            d18O_sd = sd(d18Ow),
            sigma_mean = mean(sigma),
            sigma_sd = sd(sigma)) |> 
  mutate_if(is.numeric, round, 1)

results |> 
  ggplot(mapping = aes(x = temperature)) + 
  geom_density(adjust = 2) + 
  geom_vline(xintercept = c(21, 25))
