################################################################################
# Name: MBD_accessory.R
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Accessory function for MBD violin plot from combined log file directory.
################################################################################

library(tidyverse)
library(hash)

## Covariable names
  # Full dataset and/or timeframe
covar_idx <- hash("0" = "Self-diversity",
                  "1" = "Regional Temperature",
                  "2" = "Andes Elevation",
                  "3" = "Sea Level")

covar_idx_carni <- hash("0" = "Self-diversity",
                        "1" = "Regional Temperature",
                        "2" = "Andes Elevation",
                        "3" = "Sea Level",
                        "4" = "Carnivora diversity")

covar_idx_migrants <- hash("0" = "Self-diversity",
                           "1" = "Regional Temperature",
                           "2" = "Andes Elevation",
                           "3" = "Sea Level",
                           "4" = "Carnivora diversity",
                           "5" = "N.A. herbivores diversity")


## Function to get posterior distribution of G and SW
get_post <- function(dir, param = c("G", "W", "mean_SW")){
  # MCMC recap table
  recap_tbl <- read.table(paste0(dir, "/ESS_summary.txt"), 
                          sep = "\t", header = TRUE)
  #remove runs that did not converge from recap_tbl
  if(length(which(recap_tbl$ESS_posterior < 200)) > 0){
    recap_tbl <- recap_tbl[-which(recap_tbl$ESS_posterior < 200), ]
  }
  n_conv <- nrow(recap_tbl) #number of runs that converged, useful as in the name of the combined mcmc.log file
  if(param == "mean_SW"){
    #add the mean row in last position
    recap_tbl[nrow(recap_tbl)+1, ] <- apply(X = recap_tbl, MARGIN = 2, FUN = mean, na.rm = TRUE)
    #subset mean Shrinkage Weights (SW)
    mean_SW <- recap_tbl %>% select(starts_with("Mean_W"))
    return(mean_SW)
  }
  else{
    #Open combined mcmc.log file and retain the distributions of the selected G
    mcmcLog <- read.table(paste0(dir, "/combined_", n_conv, "_KEEP.log"),
                          header = TRUE, sep = "\t")
    mcmcLog <- mcmcLog %>% select(starts_with(param)) #only retain correlation parameters
    return(mcmcLog)
  }
}

## Function to get plotting dataset --------------------------------------------
out_table_MBD <- function(dir, #where the MBD log files are stored 
                          interval #time interval covered
){
  
  mcmcLog <- get_post(dir, param = "G")
  mean_SW <- get_post(dir, param = "mean_SW")
  ## 1) get column names of the SW > 0.5 ---------------------------------------
  ns_names <- colnames(mean_SW)[which(mean_SW[nrow(mean_SW), ] < 0.5)] #remember that the last one is the total
  mean_SW_sign <- mean_SW[, !(colnames(mean_SW) %in% ns_names)]
  #go back to the corresponding variable
  end_nm <- function(name){
    spl <- strsplit(name, split = "")[[1]]
    spl <- spl[(length(spl)-3):length(spl)]
    return(paste0("G", spl[1], spl[2], spl[3], spl[4])) #the "G" stands for the corr
  }
  corr_vbl <- sapply(X = colnames(mean_SW_sign),
                     FUN = end_nm)
  #subset
  if(length(corr_vbl) == 0){ # if no variable found with SW > 0.5, don't go further
    cat("\nNo significant correlation coefficient found.\n")
  }
  if(length(corr_vbl) > 0){
    mcmcLog_sign <- mcmcLog %>% select(all_of(corr_vbl))
    # 2) check if zero is in the 95% HPD
    zeros <- c()
    for(G in colnames(mcmcLog_sign)){
      #2.5 and 975.% quantiles of the distribution
      Q <- as.numeric(quantile(mcmcLog_sign[, G], probs = c(0.025, 0.975)))
      if(length(unique(sign(Q))) > 1){ #if these boundaries have different signs, i.e. 0 is in 95% HPD
        small_abs <- min(abs(Q))
        #in case the distribution is skewed and only a TINY part of the 95% HPD includes 0
        if(small_abs >= 0.01){ #we consider small_abs small enough if smaller than 1e-2
          zeros <- c(zeros, G)
        }
      }
    }
    #remove variables including zero in their 95% HPD from the list of the significant variables
    if(length(zeros) > 0){
      zeros <- str_replace(zeros, "Mean_W", "G") #otherwise names don't match
      corr_vbl <- corr_vbl[-which(corr_vbl %in% zeros)]
      if(length(corr_vbl) == 0){
        cat("\nNo significant correlation coefficient found.\n")
      }
    }
  }
  
  # 3) reformat dataset for plotting
  value <- mcmcLog[, 1]
  param <- rep(0, nrow(mcmcLog))
  col <- rep(colnames(mcmcLog)[1], nrow(mcmcLog))
  if("l" %in% strsplit(colnames(mcmcLog)[1], "")[[1]]){ #lambda
    rate <- rep("Speciation", length(mcmcLog[, 1]))
  }
  if("m" %in% strsplit(colnames(mcmcLog)[1], "")[[1]]){ #mu
    rate <- rep("Extinction", length(mcmcLog[, 1]))
  }
  
  #specify whether parameter associated to origination or extinction rate
  for(i in colnames(mcmcLog)[-1]){
    col <- c(col, rep(i, nrow(mcmcLog)))
    value <- c(value, mcmcLog[, i])
    p <- strsplit(i, split = "_")[[1]][2]
    param <- c(param, rep(as.numeric(p), nrow(mcmcLog)))
    if("l" %in% strsplit(i, "")[[1]]){ #lambda
      rate <- c(rate, rep("Speciation", nrow(mcmcLog)))
    }
    else if("m" %in% strsplit(i, "")[[1]]){ #mu
      rate <- c(rate, rep("Extinction", nrow(mcmcLog)))
    }
  }
  plot_df <- data.frame(param = param, rate = rate, col = col, value = value)
  #significance dataframe
  if(length(corr_vbl) > 0){ #if we have significant correlation coefficients
    signif_df <- plot_df %>% 
      mutate(col = ifelse(col %in% corr_vbl, "*", NA)) %>% #if the correlation coefficient was found significant, we add a star
      group_by(param, rate, col) %>%
      summarise(max_val = max(density(value)[[1]]),
                min_val = min(density(value)[[1]])) %>% 
      #adjust star position
      mutate(star_pos = ifelse(abs(max_val) >= abs(min_val), 
                               max_val + sign(max_val)*0.5,
                               min_val + sign(min_val)*0.5))
  }
  if(length(corr_vbl) == 0){ #if no coefficient was found significant
    signif_df <- plot_df %>% 
      mutate(col = NA) %>% #if the correlation coefficient was found significant, we add a star
      group_by(param, rate, col) %>%
      summarise(max_val = max(density(value)[[1]]),
                min_val = min(density(value)[[1]])) %>% 
      mutate(star_pos = ifelse(abs(max_val) >= abs(min_val), 
                               max_val + sign(max_val),
                               min_val + sign(min_val)))
    
  }
  signif_df <- signif_df %>% add_column(interval = rep(interval, nrow(signif_df)))
  # Create a column indicating (or not) significance of each coefficient (for colour attribution)
  attrib_sign <- function(idx){
    corr_idx <- which(signif_df$rate == plot_df$rate[idx] &
                        signif_df$param == plot_df$param[idx])
    type <- signif_df$rate[corr_idx] # Extinction or Origination
    signif <- signif_df$col[corr_idx] # "*" or NA
    if(type == "Extinction" & is.na(signif)){
      return("Ext_ns")
    }
    else if(type == "Extinction" & signif == "*"){
      return("Ext_signif")
    }
    else if(type == "Speciation" & is.na(signif)){
      return("Sp_ns")
    }
    else if(type == "Speciation" & signif == "*"){
      return("Sp_signif")
    }
  }
  sign_col <- sapply(X = 1:nrow(plot_df), FUN = attrib_sign)
  plot_df <- plot_df %>% add_column(signif_col = sign_col, 
                                    interval = rep(interval, nrow(plot_df)),
                                    .after = "col")
  return(list(plot_df, signif_df))
}

## Plotting function -----------------------------------------------------------
MBD.plot <- function(PLOT_DF, SIGNIF_DF,
                     x_breaks = seq(from = 0, to = 8, by = 1),
                     x_labels,
                     x_lab = NULL,
                     y_lab = "Correlation coefficient",
                     fill = NULL,
                     rate.labs,
                     int.labs,
                     vjust.star.ori = 0.1,
                     vjust.star.ext = 0.1,
                     time_facetting = TRUE){
  p <- ggplot(data = PLOT_DF, aes(x = factor(param), y = value)) +
    # axes
    scale_y_continuous(limits = c(min(SIGNIF_DF$min_val-1), 
                                  max(SIGNIF_DF$max_val+1))) +
    scale_x_discrete(breaks = x_breaks,
                     labels = x_labels) +
    labs(x = x_lab,
         y = y_lab,
         fill = fill)
  
  # add grey bands
  nvar <- length(unique(PLOT_DF$col)) / 2
  i <- 1
  p <- p + annotate(geom = "rect", xmin = -Inf, xmax = i+0.5, ymin = -Inf, ymax = Inf, fill = "grey95")
  while(i <= nvar - 2){
    p <- p + annotate(geom = "rect", xmin = i + 1.5, xmax = i + 2.5, ymin = -Inf, ymax = Inf, fill = "grey95")
    i <- i + 2
  }
  palette <- c("#fcbba1", "#a50f15", "#9ecae1", "#08519c") # non-significant correlation coefficients are displayed in light colours
  # if no variable is significant
  if(length(unique(PLOT_DF$signif_col)) == 2){
    palette <- c("#fcbba1", "#9ecae1")
  } 
  # violins
  p <- p + geom_violin(adjust = .75, draw_quantiles = c(0.025, 0.5, 0.975), scale = "width", aes(fill = factor(signif_col))) +
    scale_fill_manual(values = palette) +
    geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60") +
    # significance star
    geom_text(data = SIGNIF_DF,
              aes(label = col,
                  y = star_pos,
                  x = param + 0.75,
                  group = col),
              vjust = rep(c(vjust.star.ext, #extinction star
                            vjust.star.ori), #origination star
                          (nrow(SIGNIF_DF)/2)),
              size = 15) +
    # theme aesthetics
    theme(axis.title = element_text(size = 18),
          axis.text.x = element_text(size = 18, vjust = 0.2),
          axis.text.y = element_text(size = 18, hjust = 0.5),
          axis.ticks.y = element_blank(),
          legend.position = "none",
          strip.text.x = element_text(size = 18),
          strip.text.y = element_text(size = 18),
          strip.background = element_rect(colour = "black", fill = "bisque2"),
          panel.background = element_blank(),
          panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5)) +
    coord_flip()
  if(time_facetting){
    p <- p + facet_grid(interval~rate, labeller = labeller(rate = rate.labs, interval = int.labs))
  }
  else{
    p <- p + facet_grid(.~rate, labeller = labeller(rate = rate.labs))
  }
  return(p)
}
