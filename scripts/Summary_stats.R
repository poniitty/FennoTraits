library(tidyverse)

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

# N of species in whole data
all %>% 
  filter(!rank %in% c("hybrid","genus","family")) %>% 
  select(taxon) %>% 
  distinct() # 374 species

# N of trait observations in whole data
all %>% 
  filter(trait != "cvr") %>% 
  nrow() # 166348 trait observations

# N of abundance observations in whole data
all %>% 
  filter(trait == "cvr") %>% 
  nrow() # 44600 species abundancy observations

# N of sites in whole data
all %>% 
  filter(design != "EXT") %>% 
  filter(design != "KIL_SEA") %>% 
  select(area, design, site) %>% 
  mutate(site = ifelse(design %in% c("KIL_WOO", "KIL_MI"), parse_number(site), site)) %>% 
  select(-design) %>% 
  distinct() %>% 
  count() # 1283 sites

# How many trait observations per area
all %>% 
  filter(trait != "cvr") %>% 
  group_by(area) %>% 
  count()

# How many unique species per area
all %>% 
  filter(!rank %in% c("hybrid","genus","family")) %>%
  select(area, taxon) %>% 
  distinct() %>% 
  group_by(area) %>% 
  count()
  
# How many unique sites with full community per area
comm %>% 
  filter(full_community) %>%
  select(area, design, site) %>% 
  distinct() %>% 
  group_by(area) %>%
  count()

# Study sites per study design in Kilpisjärvi
all %>% 
  filter(area == "KIL") %>% 
  filter(design != "EXT") %>% 
  select(area, design, site) %>% 
  mutate(site = ifelse(design %in% c("KIL_WOO", "KIL_MI"), parse_number(site), site)) %>% 
  distinct() %>% 
  group_by(design) %>%
  count()

# Unique species per study design in Kilpisjärvi
all %>% 
  filter(area == "KIL") %>% 
  filter(design != "EXT") %>% 
  filter(!rank %in% c("hybrid","genus","family")) %>% 
  select(area, design, taxon) %>% 
  distinct() %>% 
  group_by(design) %>%
  count()

# Unique trait observation per study design in Kilpisjärvi
all %>% 
  filter(area == "KIL") %>% 
  filter(design != "EXT") %>% 
  filter(trait != "cvr") %>% 
  select(area, design, trait, value) %>% 
  group_by(design) %>%
  count()

######################################
# Per trait

# obs
all %>% 
  group_by(trait) %>%
  count()

# species
all %>% 
  filter(!rank %in% c("hybrid","genus","family")) %>% 
  select(trait, taxon) %>% 
  distinct() %>% 
  group_by(trait) %>%
  count()

# sites
all %>% 
  filter(design != "EXT") %>% 
  filter(design != "KIL_SEA") %>% 
  mutate(site = ifelse(design %in% c("KIL_WOO", "KIL_MI"), parse_number(site), site)) %>% 
  select(trait, site) %>% 
  distinct() %>% 
  group_by(trait) %>%
  count()
