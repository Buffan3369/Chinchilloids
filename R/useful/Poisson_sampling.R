################################################################################
# Name: Poisson_sampling.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Functions to carrying out virtual occurrence sampling as a Poisson 
#              Process with piecewise-constant intensity.
################################################################################

## Combine posterior distributions of q rates across PyRate replicates ---------
combine_q_distribs <- function(MCMC_path, # Folder where MCMClog files are stored
                               burnin = 0.01,
                               resample = 1000){
  logfiles <- list.files(path = MCMC_path, pattern = "_mcmc.log",
                         full.names = T)
  # Initialisation
  file <- logfiles[1]
  f <- read.table(file, sep = "\t", header = T)
  start <- burnin*nrow(f)+1
  f <- f[start:nrow(f),]
  q_table <- f |> dplyr::select(contains("q_"))
  # Loop
  for(file in logfiles[-1]){
    f <- read.table(file, sep = "\t", header = T)
    start <- burnin*nrow(f)+1
    f <- f[start:nrow(f),]
    q_table <- rbind.data.frame(q_table, 
                                f |> dplyr::select(contains("q_")))
  }
  # Resample
  if(is.numeric(resample)){
    selected_idx <- runif(n = resample,
                          min = 1, max = nrow(q_table))
    q_table <- q_table[selected_idx,]
  }
  return(q_table)
}


## Sample within a given CI (only designed for sample of size 1) ---------------
sampleCI <- function(distrib,
                     level = 0.95){
  qtls <- quantile(distrib, probs = c((1-level)/2, 1-(1-level)/2))
  s <- sample(x = distrib, size = 1)
  while(s < qtls[1] | s > qtls[2]){
    s <- sample(x = distrib, size = 1)
  }
  return(s)
}

## Carry out Poisson sampling --------------------------------------------------
time_varying_sampling <- function(s_sp,         # Corrected age (Calderón del Cid et al. 2024)
                                  meanQ_tbl,    # Preservation rate table in the form returned by parse_Q_rates.py
                                  q_distribs    # Output from combine_q_distribs()
                                  ){   
  diff_tq <- meanQ_tbl$Age - s_sp
  last_bins <- which(diff_tq < 0)
  # if s_sp comprised within the last q bin
  if(length(last_bins) == 0){
    times_qshift <- s_sp 
    # Sample within the 95% HPD of the posterior distribution of Q
    q_ssp <- sampleCI(distrib = q_distribs[, ncol(q_distribs)])
  }
  # otherwise
  else{
    times_qshift <- rev(meanQ_tbl$Age[last_bins]) # rev() as backwards-in-time
    q_ssp <- c()
    start <- last_bins[1]-1 # don't forget the bin before
    for(bin_idx in c(start, last_bins)){
      q_ssp <- c(q_ssp,
                 sampleCI(distrib = q_distribs[, bin_idx]))
    }
    q_ssp <- rev(q_ssp)
  }
  # Sampling Scheme (Poisson process with time-varying intensity)
  i <- 1
  q <- q_ssp[i]
  waiting <- c()
  BIG_T <- 0
  while(BIG_T < s_sp){
    while(BIG_T < times_qshift[i]){
      new_t <- rexp(n = 1, rate = q)
      waiting <- c(waiting, new_t)
      BIG_T <- BIG_T + new_t
    }
    i <- i+1
    if(i > length(times_qshift)){break}
    q <- q_ssp[i]
  }
  events <- cumsum(waiting)
  # Remove potential events occurring before s_sp
  if(length(which(events > s_sp)) > 0){
    events <- events[-which(events > s_sp)]
  }
  return(events)
}
