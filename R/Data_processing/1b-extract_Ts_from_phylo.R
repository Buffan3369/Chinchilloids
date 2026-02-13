### ------------------------------------------------------------------------ ###
###      EXTRACT ORIGINATION AND EXTINCTION TIMES OF EXTANT CAVIOMORPHA      ###
#   We use the dated mammal tree produced by Álvarez-Carretero et al. (2022)   #
### ------------------------------------------------------------------------ ###

library(ape)

dated_MCC_Mammalia <- read.tree("./Data/Álvarez-Carretero_etal_2022_tree/timetrees/01_step2/4705sp_mean.nwk")

## Genera
mamm_gen <- sapply(X = dated_MCC_Mammalia$tip.label, 
                   FUN = function(x){
                     spl <- strsplit(x, split = "_")[[1]]
                     return(spl[1])
                   })

chinchi_gen <- c("chinchilla", "dinomys", "lagidium", "lagostomus")
chinchi_tips <- dated_MCC_Mammalia$tip.label[which(mamm_gen %in% chinchi_gen)]

chinchi_tree <- keep.tip(phy = dated_MCC_Mammalia, tip = chinchi_tips)

branching.times(chinchi_tree)

plot(chinchi_tree)


pachi_gen <- c("loxodonta", "hippopotamus", "rhinoceros", "dendrolagus")
pachi_tips <- dated_MCC_Mammalia$tip.label[which(mamm_gen %in% pachi_gen)]

pachi_tree <- keep.tip(phy = dated_MCC_Mammalia, tip = pachi_tips)

pdf("~/Bureau/pachi_tree.pdf", height = 5, width = 10)
plot(pachi_tree)
dev.off()
