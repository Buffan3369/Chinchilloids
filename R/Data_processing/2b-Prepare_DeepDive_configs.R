################################################################################
# Name: 2b-Prepare_DeepDive_configs.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Prepare DeepDive configs for Chinchilloid analyses
################################################################################

library(DeepDiveR)
library(hash)

## Define some loop parameters -------------------------------------------------

bins <- seq(from = 39, to = 0, by = -1)


for(lvl in c("genus", "species")){
  ############################# SIMULATOR #############################
  # Initialise config file
  config_sim <- create_config(
    name = lvl,
    data_file = paste0(lvl, "/data/Chinchilloidea_", lvl, "_level_DD_input.csv"), #useless here
    bins = bins,
    n_regions = as.integer(3),
    present_diversity = ifelse(lvl == "genus", 4, 6),
    simulate = TRUE,
    model_training = FALSE,
    empirical_predictions = FALSE)
  # Working directory on BIGMEM
  edit_config(config = config_sim,
              module = "general",
              parameter = "wd",
              value = "./") 
  # Set the number of CPUs used to carry out simulations to 10
  edit_config(config = config_sim,
              module = "simulations",
              parameter = "n_CPUS",
              value = 20)
  # Set the number of training datasets to 150,000
  edit_config(config = config_sim,
              module = "simulations",
              parameter = "n_training_simulations",
              value = 150000)
  # Set the number of test datasets to 1,000
  edit_config(config = config_sim,
              module = "simulations",
              parameter = "n_test_simulations",
              value = 1000)
  # Choose the number of starting species between 1 and 5
  edit_config(config = config_sim,
              module = "simulations",
              parameter = "s_species",
              value = c(1, 5))
  # Set the number of extant species between 0 and 1000 (in simulations)
  edit_config(config = config_sim,
              module = "simulations",
              parameter = "extant_sp",
              value = c(0, 1000))
  # Folder issues
  edit_config(config = config_sim,
              module = "simulations",
              parameter = "sim_name",
              value = paste0("simulation_", lvl, "_ET"))
  edit_config(config = config_sim,
              module = "simulations",
              parameter = "sims_folder",
              value = paste0(lvl, "/simulations"))
  edit_config(config = config_sim,
              module = "model_training",
              parameter = "sims_folder",
              value = "./") # 'otherwise doesn't work
  edit_config(config = config_sim,
              module = "model_training",
              parameter = "model_folder",
              value = paste0(lvl, "/", lvl, "_models"))
  edit_config(config = config_sim,
              module = "model_training",
              parameter = "f",
              value = paste0(lvl, "/", lvl, "_feature"))
  edit_config(config = config_sim,
              module = "model_training",
              parameter = "l",
              value = paste0(lvl, "/", lvl, "_label"))
  
  # Save
  config_sim$write(paste0("./Results/DeepDive/", lvl, "/configs/Config_sim_", lvl, ".ini"))
  
  ####### TRAIN, TEST, EVALUATE AND PREDICT WITH DIFFERENT ARCHITECTURES #######
  ## LSTM 64 32, dense layer 32
  config_pred1 <- create_config(
    name = lvl,
    data_file = paste0(lvl, "/data/Chinchilloidea_", lvl, "_level_DD_input.csv"),
    bins = bins,
    n_regions = as.integer(3),
    present_diversity = ifelse(lvl == "genus", 4, 6),
    simulate = FALSE,
    model_training = TRUE,
    empirical_predictions = TRUE)
  # Remove simulation part of the config
  config_pred1$data <- config_pred1$data[-2]
  # Working directory on BIGMEM
  edit_config(config = config_pred1,
              module = "general",
              parameter = "wd",
              value = "./") 
  # Simulation folder
  edit_config(config = config_pred1,
              module = "model_training",
              parameter = "sims_folder",
              value = paste0(lvl, "/simulations")) 
  # Model folder
  edit_config(config = config_pred1,
              module = "model_training",
              parameter = "model_folder",
              value = paste0(lvl, "/", lvl, "_models")) 
  # Set the dropout fraction
  edit_config(config = config_pred1,
              module = "model_training",
              parameter = "dropout",
              value = 0.05)  
  # Set architecture of lstm layers
  edit_config(config = config_pred1,
              module = "model_training",
              parameter = "lstm_model_1",
              value = c(64, 32))
  # Set fully-connected layers
  edit_config(config = config_pred1,
              module = "model_training",
              parameter = "dense_model_1",
              value = c(32))
  # Set max nb of trainig epochs to 150 (1000 was useless)
  edit_config(config = config_pred1,
              module = "model_training",
              parameter = "max_epochs",
              value = 150)
  # Output file parameters
  edit_config(config = config_pred1,
              module = "empirical_predictions",
              parameter = "model_folder",
              value = paste0(lvl, "/", lvl, "_models"))
  edit_config(config = config_pred1,
              module = "empirical_predictions",
              parameter = "output_file",
              value = paste0(lvl, "/", lvl, "_output"))
  config_pred1$write(paste0("./Results/DeepDive/", lvl, "/configs/Config_pred_", lvl, "-lstm_64_32-d_32.ini"))
  
  ## LSTM 64 32, Dense layer 64 32
  config_pred3 <- config_pred1
  edit_config(config = config_pred3,
              module = "model_training",
              parameter = "dense_model_1",
              value = c(64, 32))
  config_pred3$write(paste0("./Results/DeepDive/", lvl, "/configs/Config_pred_", lvl, "-lstm_64_32-d_64_32.ini"))
  
  ## LSTM 128 64 32, Dense layer 64 32
  config_pred4 <- config_pred3
  edit_config(config = config_pred4,
              module = "model_training",
              parameter = "lstm_model_1",
              value = c(128, 64, 32))
  config_pred4$write(paste0("./Results/DeepDive/", lvl, "/configs/Config_pred_", lvl, "-lstm_128_64_32-d_64_32.ini"))
  
  ## LSTM 128 64 32, Dense layer 32
  config_pred5 <- config_pred4
  edit_config(config = config_pred5,
              module = "model_training",
              parameter = "dense_model_1",
              value = c(32))
  config_pred5$write(paste0("./Results/DeepDive/", lvl, "/configs/Config_pred_", lvl, "-lstm_128_64_32-d_32.ini"))
  
  ## LSTM 32, Dense layer 32
  config_pred6 <- config_pred5
  edit_config(config = config_pred6,
              module = "model_training",
              parameter = "lstm_model_1",
              value = c(32))
  edit_config(config = config_pred6,
              module = "model_training",
              parameter = "dense_model_1",
              value = c(32))
  config_pred6$write(paste0("./Results/DeepDive/", lvl, "/configs/Config_pred_", lvl, "-lstm_32-d_32.ini"))
}