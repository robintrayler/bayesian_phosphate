library(tidyverse)
library(colorspace)
library(ggridges)
theme_set(theme_minimal())
source('./R/model_water_temperature.R')
# load the endothermic data ---------------------------------------------------
data <- read_csv(file = './data/data.csv') %>%
  filter(thermo == 'Endo') 

# get the unique groups 
groups <- unique(data$group)

# create a list to store the results 
results <- list()

# set MCMC parameters 
iterations = 50000
burn = 5000

for(i in seq_along(groups)) {
  # subset the current group 
  dat <- data %>% 
    filter(group == groups[i])
  
  temp_range  <- c(10, 45)
  d18Ow_range <- c(dat$d18Ow_min[1], dat$d18Ow_max[1])
  
  results[[i]] <- model_water_temperature(
    d18Op = dat$d18Op,
    d18Op_sd = 0.2,
    temperature_prior_param = temp_range, # uniform range
    temperature_prior_type = 'uniform',
    water_prior_param = d18Ow_range, # mean and sd
    water_prior_type = 'uniform',
    iterations = iterations, 
    sigma_prior_param = 1,
    burn = burn,
    equation = 'kolodny') %>% 
    add_column(group = groups[i])
}

# collapse back into a data frame
results <- reduce(results, rbind)
write_csv(x = results, file = './data/endo_grouped_posterior.csv')
