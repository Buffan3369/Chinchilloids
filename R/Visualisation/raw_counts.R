
## Function to plot occs through time ------------------------------------------
occ_through_time <- function(data, what="occ"){ 
  #what="occ" => occurrence count
  #what="div_gen" => genus count
  #what="div_spec" => species count
  if(what == "div_gen"){
    data <- data %>%
      group_by(genus, min_ma, max_ma) %>%
      distinct(genus) %>% 
      ungroup()
  }
  else if(what == "div_spec"){
    data <- data %>%
      group_by(accepted_name, min_ma, max_ma) %>%
      distinct(accepted_name) %>% 
      ungroup()
  }
  max_ma_count <- data %>% count(max_ma)
  min_ma_count <- data %>% count(min_ma)
  
  time_ttl <- unique(sort(c(max_ma_count$max_ma, min_ma_count$min_ma), decreasing = TRUE))
  
  cumul_occ <- c(0)
  for(i in 1:length(time_ttl)){
    t <- time_ttl[i]
    N <- cumul_occ[i] #previous
    if(t %in% max_ma_count$max_ma == FALSE){ #necessarily in min_ma_count only
      idx <- which(min_ma_count$min_ma == t)
      cumul_occ <- c(cumul_occ, (N - min_ma_count$n[idx])) #counmin_mad negatively, min age of the occ(s)
    }
    else if(t %in% min_ma_count$min_ma == FALSE){ #necessarily in max_ma_count only
      idx <- which(max_ma_count$max_ma == t)
      cumul_occ <- c(cumul_occ, (N + max_ma_count$n[idx])) #counted positively, max age of the occ(s)
    }
    else{ #t both in min and max ages
      idx_min <- which(min_ma_count$min_ma == t)
      idx_max <- which(max_ma_count$max_ma == t)
      cumul_occ <- c(cumul_occ, rep((N + max_ma_count$n[idx_max] - min_ma_count$n[idx_min]), length(idx_max))) #birth - death
    }
  }
  return(list(time_ttl, cumul_occ))
}

## Occurrences -----------------------------------------------------------------
occ_tot <- occ_through_time(data = chinchi, what = "div_gen")
occ_E <- occ_through_time(data = chinchi %>% filter(loc == "E"), what = "div_gen")
occ_T <- occ_through_time(data = chinchi %>% filter(loc == "T"), what = "div_gen")
occ_C <- occ_through_time(data = chinchi %>% filter(loc == "C"), what = "div_gen")

full_df2 <- data.frame(time = unique(c(occ_tot[[1]], occ_C[[1]], occ_E[[1]], occ_T[[1]])),
                      div_tot = NA,
                      div_E = NA,
                      div_T = NA,
                      div_C = NA)

for(t in full_df2$time){
  if(t %in% occ_tot[[1]]){
    wh <- occ_tot[[2]][which(occ_tot[[1]] == t)]
    full_df2$div_tot[which(full_df2$time == t)] <- wh
  }
  if(t %in% occ_E[[1]]){
    wh <- occ_E[[2]][which(occ_E[[1]] == t)]
    full_df2$div_E[which(full_df2$time == t)] <- wh
  }
  if(t %in% occ_T[[1]]){
    wh <- occ_T[[2]][which(occ_T[[1]] == t)]
    full_df2$div_T[which(full_df2$time == t)] <- wh
  }
  if(t %in% occ_C[[1]]){
    wh <- occ_C[[2]][which(occ_C[[1]] == t)]
    full_df2$div_C[which(full_df2$time == t)] <- wh
  }
}

# Erase NAs
  # Tot
i <- 1
while(i <= nrow(full_df2)){
  j <- 0
  dE <- full_df2$div_tot[i+j]
  while(is.na(dE)){
    j <- j+1
    dE <- full_df2$div_tot[i+j]
  }
  full_df2$div_tot[i:(i+j-1)] <- dE
  i <- i+j+1
}
  # Etrop
i <- 1
while(i <= nrow(full_df2)){
  j <- 0
  dE <- full_df2$div_E[i+j]
  while(is.na(dE)){
    j <- j+1
    dE <- full_df2$div_E[i+j]
  }
  full_df2$div_E[i:(i+j-1)] <- dE
  i <- i+j+1
}
  # Trop
i <- 1
while(i <= nrow(full_df2)){
  j <- 0
  dE <- full_df2$div_T[i+j]
  while(is.na(dE)){
    j <- j+1
    dE <- full_df2$div_T[i+j]
  }
  full_df2$div_T[i:(i+j-1)] <- dE
  i <- i+j+1
}
  # Car
i <- 1
while(i <= nrow(full_df2)){
  j <- 0
  dE <- full_df2$div_C[i+j]
  while(is.na(dE)){
    j <- j+1
    dE <- full_df2$div_C[i+j]
  }
  full_df2$div_C[i:(i+j-1)] <- dE
  i <- i+j+1
}

pdf("./Figures/occ_through_time.pdf", height = 3, width = 8)
par(mfrow = c(1,3))

plot(x = full_df$time, y = full_df$div_tot, type = "l", col = "black",
     main = "Occurrences through time", xlab = "Time (My)", ylab = "Nb. Occ", lwd = 3)
lines(x = full_df$time, y = full_df$div_E, col = "blue", lty = 2)
lines(x = full_df$time, y = full_df$div_T, col = "green", lty = 2)
lines(x = full_df$time, y = full_df$div_C, col = "red", lty = 2)

plot(x = full_df1$time, y = full_df1$div_tot, type = "l", col = "black",
     main = "Species through time", xlab = "Time (My)", ylab = "Nb. Occ", lwd = 3)
lines(x = full_df1$time, y = full_df1$div_E, col = "blue", lty = 2)
lines(x = full_df1$time, y = full_df1$div_T, col = "green", lty = 2)
lines(x = full_df1$time, y = full_df1$div_C, col = "red", lty = 2)
legend(25, 85, legend=c("Total", "Extratropical", "Tropical", "Caribbea"),
       col=c("black", "blue", "green", "red"), lty=c(1,2,2,2), cex=0.5)


plot(x = full_df2$time, y = full_df2$div_tot, type = "l", col = "black",
     main = "Genera through time", xlab = "Time (My)", ylab = "Nb. Occ", lwd = 3)
lines(x = full_df2$time, y = full_df2$div_E, col = "blue", lty = 2)
lines(x = full_df2$time, y = full_df2$div_T, col = "green", lty = 2)
lines(x = full_df2$time, y = full_df2$div_C, col = "red", lty = 2)
dev.off()

