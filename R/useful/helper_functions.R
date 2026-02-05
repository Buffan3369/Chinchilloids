################################################################################
# Name: helper_functions.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: some helper functions to be sourced.
################################################################################

library(tidyverse)

## Function to select the closest 'age_vect' element to the integer 'int_age' --------------------------------------
select_closer <- function(int_age, age_vect){
  diff <- sapply(X = age_vect, FUN = function(x){return(abs(x-int_age))})
  return(which.min(diff))
}

## Underscore ------------------------------------------------------------------
udsc <- function(name){
  spl <- strsplit(name, split = " ")[[1]]
  if(length(spl) == 1){
    return(name)
  }
  else{
    return(paste(spl, collapse = "_"))
  }
}

## Standardised table writing --------------------------------------------------
write.table.lucas <- function(...){
  write.table(sep = "\t",
              na = "",
              row.names = FALSE,
              quote = FALSE,
              ...)
}

## Standardised plotting theme -------------------------------------------------
theme_lucas <- function(...){
  theme(panel.background = element_blank(),
        panel.border = element_rect(linewidth = .75, colour = "black", fill = NA),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 9),
        plot.title = element_text(size = 12, hjust = 0.5),
        ...)
}

## Function checking whether a `taxon_name` comprises open nomenclature --------
open_checkR <- function(x){
  a <- TRUE
  spl <- strsplit(x, split = "_")[[1]]
  if("cf." %in% spl | "aff." %in% spl | "?" %in% strsplit(x, split = "")[[1]]){
    a <- FALSE
  }
  return(a)
}

## Function to assess number of occurrences through time -----------------------
occ_through_time <- function(data, what="occ"){ 
  #what="occ" => occurrence count
  #what="div_gen" => genus count
  #what="div_spec" => species count
  #what="deposits" => fossil deposits through time 
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
  else if(what == "deposits"){
    data <- data %>% 
      group_by(lng, lat, min_ma, max_ma) %>%
      distinct(lng, lat) %>% 
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

## Body mass reclassifier ------------------------------------------------------
bm_reclass <- function(x){
  if(is.na(x)){
    return(NA)
  }
  else if(x < 500){
    return(1) # XS
  }
  else if(x < 1000){
    return(2) # S
  }
  else if(x < 1e4){
    return(3) # M
  }
  else if(x < 1e5){
    return(4) # L
  }
  else if(x < 2e5){
    return(5) # XL
  }
  else if(x > 2e5){
    return(6) # XXL
  }
  else{
    return(NA)
  }
}

## Hypsodonty reclassifier ------------------------------------------------------
hypso_reclass <- function(x){
  if(x == "brachydont"){
    return(0)
  }
  else if(x == "mesodont"){
    return(1)
  }
  else if(x == "protohypsodont"){
    return(2)
  }
  else if(x == "euhypsodont"){
    return(3)
  }
  else{
    return(NA)
  }
}

