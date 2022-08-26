# Nonparametric Smoothing Function --------------------------------------------
gaussian_smooth <- function(x, y, xmod = x, winsize){
  ## INPUTS
  ## x = x values
  ## y = yvalues
  ## xmod = positions to calculate statistics at. default is data positions
  ## winsize = standard deviation for gaussian kernel
  ## OUTPUTS
  ## mean = ymod = the weighted moving mean
  ## sd = ymodsd = the weighted moving standard deviation
  ## se = ymodse = the weighted moving standard error
  ymod <- vector(length = length(xmod)) # preallocate
  ymodsd <- vector(length = length(xmod)) # preallocate
  ymodse <- vector(length = length(xmod)) # preallocate
  
  for (i in 1:length(xmod)) { # for each value in xmod
    w <- dnorm(x, xmod[i], winsize) # weights 
    ymod[i] <- sum(w * y) / sum(w) # calculate the moving weighted mean
    ymodsd[i] <- sum(w * (y - ymod[i]) ^ 2) / sum(w) # moving standard deviation
    ymodse[i] <- ymodsd[i] / sqrt(sum(w)) # moving standard error
  }
  
  return(data.frame(mean = ymod, # return the results
               sd = ymodsd, 
               se = ymodse)) 
}