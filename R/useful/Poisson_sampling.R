################################################################################
# Name: 1abis-Playaround_SpeciesAge.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Function carrying out virtual occurrence sampling as a Poisson 
#              Process with piecewise-constant intensity.
################################################################################

time_varying_sampling <- function(s_sp,     # Corrected age
                                  q_tbl){   # Preservation rate table in the form returned by parse_Q_rates.py
  diff_tq <- q_tbl$Age - s_sp
  last_bins <- which(diff_tq < 0)
  # if s_sp comprised within the last q bin
  if(length(last_bins) == 0){
    times_qshift <- s_sp 
    q_ssp <- q_tbl$mean_Q[nrow(q_tbl)]
  }
  # otherwise
  else{
    times_qshift <- rev(q_tbl$Age[last_bins]) # rev() as backwards-in-time
    q_ssp <- rev(q_tbl$mean_Q[c(last_bins[1]-1, # don't forget the bin before
                                last_bins)])
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