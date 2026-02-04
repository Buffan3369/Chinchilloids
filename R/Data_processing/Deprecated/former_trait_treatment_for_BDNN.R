# Import taxon list
TaxonList <- read.table("./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_TaxonList.txt", header = T)
categorical_traits <- data.frame(Species = TaxonList$Species,
                                 Body_mass = NA,
                                 Hypsodonty = NA)

### Body mass ###
bm_df <- readRDS("./Data/Traits/ChinchilloideaCombined_BodyMass.RDS")
#   # Save the median
# median_bm_class <- median(bm_df$BM_class, na.rm = T)
# transf_features_tbl$Body_mass <- c(median_bm_class, 1) # sd = 1 as discrete categories
# Scale
# bm_df <- bm_df %>% mutate(BM_class = (BM_class - median_bm_class))
categorical_traits <- categorical_traits %>% 
  mutate(Body_mass = sapply(X = Species,
                            FUN = function(x){
                              if(x %in% bm_df$Taxon){
                                return(bm_df$BM_class[which(bm_df$Taxon == x)])
                              }
                              else{
                                return(NA)
                              }
                            }))

### Hypsodonty ###
# For taxa in phylogeny
hypso_df_phylo <- read.table("./Data/Traits/ChinchilloideaPhylo_Hypso.txt")
colnames(hypso_df_phylo) <- c("Taxon", "Hypsodonty")
# Turn categories to numbers
hypso_df_phylo <- hypso_df_phylo %>% 
  mutate(Hypsodonty_class = sapply(X = Hypsodonty, FUN = hypso_reclass)) %>% 
  select(!Hypsodonty)

# Others
hypso_others <- read_xlsx("./Data/Traits/Hypsodonty_Missing_Chinchi.xlsx")
hypso_others <- hypso_others %>% 
  select(!Reference) %>% 
  mutate(Hypsodonty_class = sapply(X = Hypsodonty_class,
                                   FUN = function(x){
                                     if(x == "?"){
                                       return(NA)
                                     }
                                     else{
                                       return(x)
                                     }
                                   }))
# Combine
hypso_df <- rbind.data.frame(hypso_df_phylo, hypso_others)
hypso_df <- hypso_df %>% mutate(Hypsodonty_class = as.numeric(Hypsodonty_class))
#   # Save the median
# med_hyp <- median(hypso_df$Hypsodonty_class, na.rm = T)
# transf_features_tbl$Hypsodonty <- c(med_hyp, 1)
# Scale
# hypso_df <- hypso_df %>% mutate(Hypsodonty_class = (Hypsodonty_class - med_hyp))
categorical_traits <- categorical_traits %>% 
  mutate(Hypsodonty = sapply(X = Species,
                             FUN = function(x){
                               if(x %in% hypso_df$Taxon){
                                 return(hypso_df$Hypsodonty_class[which(hypso_df$Taxon == x)])
                               }
                               else{
                                 return(NA)
                               }
                             }))

