# load required packages and functions ----------------------------------------
library(tidyverse)
library(viridis)
library(RColorBrewer)
theme_set(theme_minimal())
source('./R/adaptive_update.R')
source('./R/truncated_random_normal.R')
source('./R/truncated_standard_normal.R')
# load the data ---------------------------------------------------------------
sharks <- read_csv(file = './Data/meg_project_data.csv') %>% 
  filter(age == 'Miocene' & Basin == "Paratethys") %>% 
  filter(!is.na(d18Op))

temperature_prior_param <- c(5, 35)
# water mean and sd
water_prior_param <- c(-0.5, 0.5)

iterations = 10000
burn = iterations/10


model_water_temperature <- function(d18Op,
                                    temperature_prior_param,
                                    water_prior_param, 
                                    iterations = 10000, 
                                    burn = iterations/10,
                                    likelihood = 'longinelli') {
  
  # set up initial parameters for modeling --------------------------------------
  temp_prior_prob <- function(x, min, max) {
    dunif(x, min = min, 
          max = max, 
          log = TRUE)
  }
  
  # define prior probability of water following values from @shackleton1975
  # for a well mixed ocean
  water_prior_prob <- function(x, mu, sig) {
    dnorm(x, mean = mu, 
          sd = sig, 
          log = TRUE)
  }
  
  # set up the model ------------------------------------------------------------
  parameter_storage <- matrix(nrow = iterations,
                              ncol = 3)
  LL <- vector(length = iterations)
  
  # pick some starting values 
  d_water <- rnorm(1, 
                   water_prior_param[1], 
                   water_prior_param[2])
  temp <- runif(1, 
                min = temperature_prior_param[1], 
                max = temperature_prior_param[2])
  
  sig <- sd(d18Op)
  # calculate initial probability
  mu <- d_water - (temp - 111.4) / 4.3
  
  likelihood <- dnorm(d18Op, 
                      mu, 
                      sig, 
                      log = TRUE) %>% sum()
  
  prior_t <- temp_prior_prob(temp, 
                             min = temperature_prior_param[1], 
                             max = temperature_prior_param[2])
  prior_water <- water_prior_prob(d_water, 
                                  water_prior_param[1], 
                                  water_prior_param[2])
  
  LL[1] <- likelihood + prior_t + prior_water
  
  # store the initial values 
  parameter_storage[1, 1] <- d_water
  parameter_storage[1, 2] <- temp
  parameter_storage[1, 3] <- sig
  
  pb <- progress::progress_bar$new(total = iterations,
                                   format = '[:bar] :percent eta: :eta')
  for(i in 2:iterations) {
    pb$tick()
    # store the previous iteration
    parameter_storage[i, ] <- parameter_storage[i - 1, ]
    LL[i] <- LL[i - 1]
    # propose new values -------------------------------------
    d_water <- adaptive_update(chain = parameter_storage[, 1],
                               i = i)
    temp <- adaptive_update(chain = parameter_storage[, 2],
                            i = i)
    sig <- adaptive_update(chain = parameter_storage[, 3],
                           i = i,
                           lower = 0)
    
    
    # calculate probabilities -------------------------------
    mu <- d_water - (temp - 111.4) / 4.3
    
    likelihood <- dnorm(d18Op, 
                        mu, 
                        sig, 
                        log = TRUE) %>% sum()
    prior_t <- temp_prior_prob(temp, 
                               min = temperature_prior_param[1], 
                               max = temperature_prior_param[2])
    prior_water <- water_prior_prob(d_water, 
                                    water_prior_param[1], 
                                    water_prior_param[2])
    
    
    a <- likelihood + prior_t + prior_water
    
    # use a M-H algorithm
    if(is.finite(a)){
      if(!is.na(a)) {
        if(exp(a - LL[i-1]) > runif(1)) {
          parameter_storage[i, 1] <- d_water
          parameter_storage[i, 2] <- temp
          parameter_storage[i, 3] <- sig
          LL[i] <- a
        }
      }
    }
  }
}
}



parameter_storage <- parameter_storage %>% 
  as.data.frame() %>% 
  setNames(c('d18Ow', 'temperature', 'sigma')) %>% 
  add_column(iteration = 1:iterations) %>% 
  filter(iteration > burn)

# define prior's for plotting 
d18O_water <- tibble(d18O_water = seq(-3, 3, by = 0.01)) %>% 
  mutate(density = water_prior_prob(d18O_water) %>% exp())

temperature_prior <- 
  data.frame(
    temperature = seq(0, 40, by = 0.1)
  ) %>% 
  mutate(density = temp_prior_prob(temperature, min, max))

p1 <- parameter_storage %>% 
  ggplot(mapping = aes(x = temperature,
                       y=..density..)) + 
  
  geom_histogram(fill = '#756BB1',
                 color = '#756BB1',
                 alpha = 0.5,
                 bins = 50) + 
  theme_minimal() + 
  geom_line(data = temperature_prior,
            mapping = aes(x = temperature,
                          y = density),
            inherit.aes = FALSE,
            color = 1,
            linetype = 'dashed',
            size = 1) +
  xlab('temperature (C)')

p2 <- parameter_storage %>% 
  ggplot(mapping = aes(x = d18Ow, 
                       y =..density..)) +
  geom_histogram(
    fill = '#3182BD',
    color = '#3182BD',
    alpha = 0.5,
    bins = 50) + 
  theme_minimal() + 
  # xlim(-2, 2) + 
  geom_line(data = d18O_water,
            mapping = aes(x = d18O_water,
                          y = density),
            inherit.aes = FALSE,
            color = 1,
            linetype = 'dashed',
            size = 1) + 
  xlab(expression(delta^18*O[water])) 


cowplot::plot_grid(p1, p2)

parameter_storage %>% 
  summarize(temperature_mean = mean(temperature),
            temperature_sd = sd(temperature),
            d18Ow_mean = mean(d18Ow),
            d18Ow_sd = sd(d18Ow),
            sigma_mean = mean(sigma),
            sigma_sd = sd(sigma)) %>% 
  round(3) %>% 
  knitr::kable()


sample <- rnorm(18000, 
                mean = 
                  parameter_storage$d18Ow - (parameter_storage$temperature - 111.4) / 4.3, 
                sd = parameter_storage$sigma)

mean(sample)
sd(sample)
mean(sharks$d18Op)
sd(sharks$d18Op)

