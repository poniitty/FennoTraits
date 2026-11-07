library(tidyverse)
library(sf)
library(terra)
library(rstac)
# install.packages("MetBrewer")
library(MetBrewer)


comm <- read_csv("data/FennoTraits_community_heights.csv")
leaf <- read_csv("data/FennoTraits_leaf_traits.csv")

predictor_dir <- tempdir()

# Internal Function to Create a Base URL with Microsoft Planetary Computer
make_vsicurl_url <- function(signed_url) {
  paste0("/vsicurl/", signed_url)  # Simple vsicurl — SAS token is already in the URL
}

# Internal Function to Create a Base URL with Microsoft Planetary Computer
make_vsicurl_url_esa <- function(base_url) {
  paste0(
    "/vsicurl", 
    "?pc_url_signing=yes",
    "&pc_collection=esa-worldcover",
    "&url=",
    base_url
  )
}

# Internal helper function to calculate a mode
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

xy <- bind_rows(comm %>% select(area, Lat, Lon) %>% distinct,
                leaf %>% select(area, Lat, Lon) %>% distinct) %>% 
  distinct() %>% 
  drop_na() %>% 
  filter(!(area == "KIL" & Lat > 69.3)) %>% 
  st_as_sf(coords = c("Lon","Lat"), crs = 4326)


for(i in unique(xy$area)){
  # i <- "MAT"
  print(i)
  p <- xy %>% filter(area == i) %>% 
    st_transform(crs = 32634)
  
  aoi <- p %>% 
    st_buffer(2000) %>% 
    st_bbox() %>% 
    st_as_sfc() %>% 
    st_as_sf()
  
  s_obj <- stac("https://planetarycomputer.microsoft.com/api/stac/v1/")
  it_obj <- s_obj %>%
    stac_search(
      collections = "cop-dem-glo-30",
      bbox = st_bbox(aoi %>% st_transform(4326)),
      limit = 1000
    ) %>%
    get_request() %>%
    items_sign(sign_fn = sign_planetary_computer())  # Sign all asset URLs
  
  juuh <- lapply(it_obj$features, function(ft) {
    # ft <- it_obj$features[[1]]
    # Access the "data" asset directly by name instead of filtering by filename
    signed_url <- ft$assets$data$href
    
    if (is.null(signed_url)) return(FALSE)
    
    full_url <- make_vsicurl_url(signed_url)
    
    # Extract clean filename (strip query string from signed URL)
    file_name <- basename(strsplit(signed_url, "\\?")[[1]][1])
    
    e <- try({
      gdal_utils(
        "warp",
        source = full_url,
        destination = file.path(predictor_dir, file_name),
        options = c(
          "-t_srs", st_crs(aoi)$wkt,
          "-te", st_bbox(aoi),
          "-tr", c(30, 30)
        )
      )
    }, silent = TRUE)
    
    if (inherits(e, "try-error")) {
      message("Failed: ", file_name)
      return(FALSE)
    } else {
      return(TRUE)
    }
  })
  
  dems <- list.files(predictor_dir, pattern = "_DEM.tif", full.names = TRUE)
  dems <- lapply(dems, function(x) {
    dem <- rast(x)
    dem[dem == 0] <- NA
    return(dem)
  })
  
  dem <- sprc(dems)
  dem <- mosaic(dem)
  dem[dem < 0] <- 0
  dem[is.na(dem)] <- 0
  
  # ESA WorldCover from STAC
  it_obj <- s_obj %>%
    stac_search(collections = "esa-worldcover",
                bbox = st_bbox(aoi %>% st_transform(4326)),
                datetime = "2021-01-01/2021-12-31",
                limit = 1000) %>%
    get_request()
  
  juuh <- lapply(it_obj$features, function(ft) {
    full_url <- make_vsicurl_url_esa(assets_url(ft) %>% sort)
    full_url <- full_url[endsWith(full_url, "_Map.tif")]
    file_names <- gsub("TIF$", "tif", basename(full_url))
    
    juuh <- lapply(seq_len(length(full_url)), function(nr) {
      suppressMessages({
        suppressWarnings({
          e <- try({
            gdal_utils(
              "warp",
              source = full_url[[nr]],
              destination = paste0(predictor_dir, "/", file_names[[nr]]),
              options = c(
                "-t_srs", st_crs(aoi)$wkt,
                "-te", st_bbox(aoi),
                "-tr", c(10, 10)
              )
            )
          }, silent = TRUE)
        })
      })
      
      if (class(e)[[1]] == "try-error") {
        return(FALSE)
      } else {
        return(TRUE)
      }
    })
  })
  
  esas <- list.files(predictor_dir, pattern = "_Map.tif", full.names = TRUE)
  esas <- lapply(esas, function(x) {
    esa <- rast(x)
    esa[esa == 0] <- NA
    return(esa)
  })
  
  esa <- sprc(esas)
  esa <- mosaic(esa, fun = "max")
  esa[esa < 0] <- 0
  esa[is.na(esa)] <- 0
  
  esa <- terra::aggregate(esa, 3, getmode)
  esa <- terra::project(esa, dem, method = "near")
  
  esa <- ifel(esa == 80, 1, NA)
  
  dem2 <- terra::focal(dem, w=5, fun="median", na.rm=TRUE)
  slope <- terrain(dem2, "slope", unit="radians")
  aspect <- terrain(dem2, "aspect", unit="radians")
  hill <- shade(slope, aspect, 40, 270)
  
  hill <- trim(hill)
  dem <- crop(dem, hill)
  esa <- crop(esa, hill)
  
  png(paste0("plots/", i, ".png"), 6, 6, units = "in", res = 150)
  plot(hill, col=grey(0:100/100), legend=FALSE, mar=c(2,2,1,4))
  plot(dem, col=  met.brewer("Hokusai3", n=100, direction = 1), alpha=0.5, add=TRUE)
  plot(esa, add = TRUE, col = "white", legend = FALSE)
  plot(p, add=T, pch=19, col="black", cex=0.5)
  dev.off()
  
  unlink(list.files(predictor_dir, full.names = TRUE))
  
}

#################################################################
# DENSITY PLOTS

# install.packages("ggridges")
library(tidyverse)
library(ggridges)

comm <- read_csv("data/FennoTraits_community_heights.csv")
leaf <- read_csv("data/FennoTraits_leaf_traits.csv")
tax <- read_csv("data/FennoTraits_species.csv")


all <- bind_rows(comm %>% 
                   select(site, design, area, taxon:max_height) %>% 
                   pivot_longer(cols = cvr:max_height, names_to = "trait", values_to = "value", values_drop_na = TRUE),
                 leaf %>% 
                   select(site, design, area, taxon, reproduction, leaf_area:ExG) %>% 
                   pivot_longer(cols = reproduction:ExG, names_to = "trait", values_to = "value", values_drop_na = TRUE)) %>% 
  left_join(.,
            tax %>% select(taxon, rank))

unique(all$trait)
all %>% 
  filter(!trait %in% c("reproduction","cvr")) %>% 
  mutate(area = factor(area, levels = rev(c("MAT","RAS","KIL","PAL","VAR","OUL","VIN")))) %>% 
  mutate(value = ifelse(trait %in% c("median_height",
                                     "max_height",
                                     "w_weight",
                                     "d_weight",
                                     "leaf_area",
                                     "SLA"), log(value), value)) %>% 
  mutate(trait = factor(trait, levels = c("median_height",
                                          "max_height",
                                          "w_weight",
                                          "d_weight",
                                          "leaf_area",
                                          "SLA",
                                          "LDMC",
                                          "BITM",
                                          "ExG"),
                        labels = c("log(Median height)",
                                   "log(Maximum height)",
                                   "log(Wet weight)",
                                   "log(Dry weight)",
                                   "log(Leaf area)",
                                   "log(SLA)",
                                   "LDMC",
                                   "Brightness index",
                                   "Grenness index"))) %>% 
  # filter(trait == "LDMC") %>% 
  ggplot(aes(x = value, y = area, fill = area)) +
  geom_density_ridges(alpha = 0.7, scale = 0.9) +
  # scale_fill_viridis_d(option = "D") +
  scale_fill_discrete(palette = met.brewer("Hokusai3", n=7, direction = 1) %>% as.character()) +
  theme_minimal() +
  facet_wrap(vars(trait), scales = "free") +
  labs(x = "Trait value",
       y = "Study area") +
  theme(axis.text.y = element_blank(),
        legend.position = "bottom")

ggsave("plots/Trait_density_ridges.pdf", width = 1961*0.7, height = 1961, units = "px")

all %>% 
  filter(!trait %in% c("reproduction","cvr")) %>% 
  ggplot(aes(y = taxon)) +
  geom_bar()

# Count occurrences of each taxon
taxon_counts <- all %>%
  filter(!trait %in% c("cvr")) %>% 
  group_by(taxon) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice_max(count, n = 30)

grp <- readxl::read_xlsx("../Fennoscandia_plant_traits/trait_data/herbario_traits.xlsx") %>% 
  rename(taxon = species)

taxon_counts <- left_join(taxon_counts, grp %>% select(taxon, functype)) %>% 
  mutate(functype = ifelse(functype %in% c("se","ru"), "g", functype))

ggplot(taxon_counts, aes(x = reorder(taxon, count), y = count, fill = functype)) +
  geom_col() +
  coord_flip() +  # Flip to make taxa labels readable
  labs(x = "Species",
       y = "Trait observation count") +
  scale_fill_discrete(palette = met.brewer("Tam", n=4, direction = 1) %>% as.character()) +
  theme_minimal() +
  theme(axis.text.y = element_text(face = "italic"),
        legend.position = "bottom")
ggsave("plots/Species_obs_counts.pdf", width = 1961*0.6, height = 1961, units = "px")

########################################################
# Fennoscandia map

library(tidyverse)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

p <- read_csv("data/FennoTraits_leaf_traits.csv") %>% 
  group_by(area) %>% 
  summarise(Lat = median(Lat, na.rm = TRUE),
            Lon = median(Lon, na.rm = TRUE)) %>% 
  st_as_sf(coords = c("Lon","Lat"), crs = 4326)

countries <- ne_countries(country = c("Finland", "Sweden", "Norway", "Russia"), scale = "medium", returnclass = "sf")

# Reproject the country borders and points to EPSG:3413
countries_polar <- st_transform(countries, crs = 3413)
p_polar <- st_transform(p, crs = 3413)

ggplot() +
  geom_sf(data = countries, fill = "lightgray", color = "black") +
  geom_sf(data = p, aes(color = "red"), size = 3) +
  coord_sf(xlim = c(10, 32), ylim = c(60, 72)) + # Adjust to focus on northern Scandinavia
  coord_sf(crs = st_crs(3413)) +
  labs(title = "Study Areas in Northern Scandinavia") +
  theme_minimal()

ggplot() +
  geom_sf(data = countries_polar, fill = "lightgray", color = "black") +
  geom_sf(data = p_polar, aes(color = "red"), size = 3) +
  coord_sf(crs = st_crs(3413)) +
  labs(title = "Study Areas in Northern Scandinavia (Polar Stereographic Projection)") +
  theme_minimal()

# Define a custom azimuthal equidistant projection centered at 20°E, 90°N
custom_crs <- "+proj=aeqd +lat_0=90 +lon_0=20 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

# Reproject the data
countries_custom <- st_transform(countries, crs = custom_crs)
p_custom <- st_transform(p, crs = custom_crs)

# Plot
ggplot() +
  geom_sf(data = countries_custom, fill = "lightgray", color = "black") +
  geom_sf(data = p_custom, aes(color = "red"), size = 1) +
  coord_sf(crs = st_crs(custom_crs)) +
  coord_sf(xlim = c(-374625.5, 566868.4), ylim = c(-2994763, -2071515)) +
  theme_minimal() +
  theme(legend.position = "none")
ggsave("plots/Fenno_map.pdf", width = 800, height = 800, units = "px")

