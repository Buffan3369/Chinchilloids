library(readxl)
library(tidyverse)
library(sf)
library(raster)

## Spatialised occurrence data -------------------------------------------------
occdb <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned.xlsx")
occdb <- occdb %>%
  mutate(lng = as.numeric(lng), lat = as.numeric(lat)) %>% 
  distinct(lng, lat)
  
## Background map --------------------------------------------------------------
nw <- st_read("../Chapter_1/data_2023/New_World_map_ecoregions/New_World_18_regions_DCsplit.shp")
# switch off the use of s2, otherwise st_union does not work
sf_use_s2(FALSE)

## Elevation -------------------------------------------------------------------
r <- raster("../Chapter_1/data_2023/New_World_map_ecoregions/South_America_topography_Boschman_2021-0_Ma.grd")
r.df <- as.data.frame(r, xy = TRUE)
colnames(r.df) <- c("lon", "lat", "elev")
r.df <- r.df %>% filter(elev >= 0)

## Plot ------------------------------------------------------------------------
occ_map <- nw %>%
  # Extract South America 
  filter(ECO_NAM %in% c("North_Mesoamerica", "Nearctic", "South_Mesoamerica") == F) %>%
  # Merge extracted polygons
  st_union() %>% 
  # Plot
  ggplot() + 
  geom_sf(lwd=0) +
  geom_tile(data = r.df, aes(x = lon, y = lat, fill = elev)) +
  scale_fill_continuous(low = "#fee391", high = "#662506") +
  geom_point(data = occdb, aes(x = lng, y = lat)) +
  labs(fill = "Elevation (m)", colour = NULL) +
  theme(axis.line = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.background = element_rect(fill = "#87aade"),
        panel.grid = element_blank(),
        plot.title = element_text(hjust = 0.5))

ggsave("./Figures/Supp/Occurrence_map_Chinchilloidea.png", plot = occ_map,
       height = 20, width = 15, units = "cm", dpi = 600)
