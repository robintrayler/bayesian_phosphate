source('./R/adaptive_update.R')
source('./R/truncated_random_normal.R')
source('./R/truncated_standard_normal.R')

model_water_temperature <- function(d18Op,
                                    d18Op_sd,
                                    temperature_prior_param,
                                    temperature_prior_type = 'uniform',
                                    water_prior_param, 
                                    water_prior_type = 'normal',
                                    sigma_prior_param  = 0.2,
                                    iterations = 10000, 
                                    burn = 500,
                                    equation = 'longinelli') {
  
  calculate_mu <- function(d_water, temp, equation) {
    switch(equation,
           'longinelli' = d_water - (temp - 111.4) / 4.30,
           'kolodny'    = d_water - (temp - 113.3) / 4.38,
           'puceat'     = d_water - (temp - 118.7) / 4.22)
    
  }
  
  model_d18Op <- function(d_water, temp, sigma, equation) {
    n = length(d_water)
    switch(equation,
           'longinelli' = rnorm(n, mean = d_water - (temp - 111.4) / 4.30, sd = sigma),
           'kolodny'    = rnorm(n, mean = d_water - (temp - 113.3) / 4.38, sd = sigma),
           'puceat'     = rnorm(n, mean = d_water - (temp - 118.7) / 4.22, sd = sigma))
    
  }
  
  # set up initial parameters for modeling --------------------------------------
  
  temp_prior_prob <- function(x, 
                              temperature_prior_param, 
                              temperature_prior_type) {
    if(temperature_prior_type == 'uniform') {
      dunif(x, 
            min = temperature_prior_param[1], 
            max = temperature_prior_param[2], 
            log = TRUE)
    } else if(temperature_prior_type == 'normal') {
      dnorm(x, 
            mean = temperature_prior_param[1], 
            sd   = temperature_prior_param[2],
            log  = TRUE)
    }
  }
  
  water_prior_prob <- function(x, 
                               water_prior_param, 
                               water_prior_type) {
    if(water_prior_type == 'uniform') {
      dunif(x, 
            min = water_prior_param[1], 
            max = water_prior_param[2], 
            log = TRUE)
      
    } else if(water_prior_type == 'normal') {
      dnorm(x, 
            mean = water_prior_param[1], 
            sd   = water_prior_param[2],
            log  = TRUE)
    }
  }
  
  # define prior probability for sigma ----------------------------------------
  sigma_prior_prob <- function(x, 
                               sigma_prior_param) {
    dexp(x    = x, 
         rate = sigma_prior_param, 
         log  = TRUE)
  }
  
  # set up the model ----------------------------------------------------------
  parameter_storage <- matrix(nrow = iterations,
                              ncol = 3)
  # pick some starting values
  
  if(water_prior_type == 'uniform') {
    d_water <- runif(1, 
                     min = water_prior_param[1], 
                     max = water_prior_param[2])
    
  } else if(water_prior_type == 'normal') {
    d_water <- rnorm(1, 
                     mean = water_prior_param[1], 
                     sd   = water_prior_param[2])
  }
  
  if(temperature_prior_type == 'uniform') {
    temp <- runif(1, 
                  min = temperature_prior_param[1], 
                  max = temperature_prior_param[2])
  } else if(temperature_prior_type == 'normal') {
    temp <- rnorm(1, 
                  mean = temperature_prior_param[1], 
                  sd   = temperature_prior_param[2])
  }
  
  sig <- sd(d18Op)
  # deal with n = 1
  if(is.na(sig)) {
    sig = 0.01
  }
  
  # calculate initial probability
  mu <- calculate_mu(d_water, temp, equation)
  
  likelihood <- dnorm(d18Op, 
                      mu, 
                      sig, 
                      log = TRUE) %>% sum()
  
  prior_t <- temp_prior_prob(temp, 
                             temperature_prior_param, 
                             temperature_prior_type)
  
  prior_water <- water_prior_prob(d_water, 
                                  water_prior_param,
                                  water_prior_type)
  
  prior_sigma <- sigma_prior_prob(sig,
                                  sigma_prior_param)
  
  
  
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
    
    # update d18Op -------------------------------------------
    d18Op_current <- rnorm(n = length(d18Op), 
                           mean = d18Op, 
                           sd = d18Op_sd)
    
    # propose new values -------------------------------------
    current_parameters <- parameter_storage[i, ]
    for(k in 1:3) {
      current_parameters[k] <- adaptive_update(chain = parameter_storage[, k],
                                               start_index = burn/2,
                                               i = i,
                                               lower = ifelse(k == 3, 0, -1000))
      
      # calculate mu
      current_mu  <- calculate_mu(current_parameters[1], 
                                  current_parameters[2], 
                                  equation)
      
      previous_mu <- calculate_mu(parameter_storage[i, 1], 
                                  parameter_storage[i, 2], 
                                  equation)
      
      # calculate likelihood
      current_likelihood <- dnorm(d18Op_current, 
                                  current_mu, 
                                  current_parameters[3], 
                                  log = TRUE) %>% 
        sum()
      
      previous_likelihood <- dnorm(d18Op_current, 
                                   previous_mu, 
                                   parameter_storage[i, 3], 
                                   log = TRUE) %>% 
        sum()
      
      # calculate priors 
      current_prior_water  <- water_prior_prob(current_parameters[1], 
                                               water_prior_param,
                                               water_prior_type)
      
      previous_prior_water <- water_prior_prob(parameter_storage[i, 1], 
                                               water_prior_param,
                                               water_prior_type)
      
      current_prior_t  <- temp_prior_prob(current_parameters[2], 
                                          temperature_prior_param, 
                                          temperature_prior_type)
      
      previous_prior_t <- temp_prior_prob(parameter_storage[i, 2], 
                                          temperature_prior_param, 
                                          temperature_prior_type)
      
      current_prior_sigma  <- sigma_prior_prob(current_parameters[3],
                                               sigma_prior_param)
      
      previous_prior_sigma <- sigma_prior_prob(parameter_storage[i, 3],
                                               sigma_prior_param)
      
      # calculate joint probability
      current_alpha  <- 
        current_likelihood + 
        current_prior_t + 
        current_prior_water + 
        current_prior_sigma
      
      previous_alpha <- 
        previous_likelihood + 
        previous_prior_t + 
        previous_prior_water + 
        previous_prior_sigma
      
      a <- current_alpha - previous_alpha
      
      if(is.finite(a)){
        if(!is.na(a)) {
          if(exp(a) > runif(1)) {
            parameter_storage[i, ] <- current_parameters
          }
        }
      }
    }
  }
  
  parameter_storage <- 
    parameter_storage %>% 
    as.data.frame() %>% 
    setNames(c('d18Ow', 'temperature', 'sigma'))
  
  parameter_storage$iteration = 1:iterations
  
  parameter_storage$d18Op_modeled = model_d18Op(parameter_storage$d18Ow, 
                                                parameter_storage$temp, 
                                                parameter_storage$sigma,
                                                equation)
  
  class(parameter_storage) <- c('phosphate_model', 'data.frame')
  
  return(parameter_storage)
}
