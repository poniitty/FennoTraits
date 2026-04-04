# FennoTraits
The up-to-date version of FennoTraits dataset.


# FennoTraits Data Dictionary

This document describes the variables in the three data files accompanying the FennoTraits dataset.

---

## 1. FennoTraits_community_heights.csv

Community-level vegetation height and cover data. Contains 42,503 records across 15 variables.

| Variable | Type | Description | Units / Values |
|---|---|---|---|
| `site` | character | Unique study site identifier, matching `site` in the other files | — |
| `design` | character | Study design the observation belongs to | — |
| `area` | character | Abbreviation of the study area | — |
| `plot_type` | character | Type of vegetation plot | a = 20cm x 20cm; b = 1m x 1m; c = circular plot with 2m radius |
| `full_community` | logical | Whether the record represents the full plant community (`TRUE`) or a focal taxon subset (`FALSE`) | TRUE / FALSE |
| `treatment` | character | Experimental treatment applied to the plot | high_LDMC = species with the highest LDMC removed; tall = the tallest species removed; low_LDMC = species with the lowest LDMC removed; random = random subset of species removed; short = the shortest species removed |
| `date` | date | Date of observation | YYYY-MM-DD |
| `year` | numeric | Year of observation | — |
| `Lat` | numeric | Latitude of the plot in decimal degrees (WGS84) |  —  |
| `Lon` | numeric | Longitude of the plot in decimal degrees (WGS84) |  —  |
| `country` | character | Country where the observation was made | FIN = Finland; NOR = Norway; SWE = Sweden |
| `taxon` | character | Taxon name as used in the dataset (may be subspecies, species, genus, or family) | — |
| `cvr` | numeric | Percentage cover of the taxon in the plot | % (0.25 – 100) |
| `median_height` | numeric | Median vegetation height of the taxon in the plot. | cm |
| `max_height` | numeric | Maximum vegetation height of the taxon in the plot | cm |

---

## 2. FennoTraits_leaf_traits.csv

Individual leaf-level functional trait measurements. Contains 22,414 records across 18 variables.

| Variable | Type | Description | Units / Values |
|---|---|---|---|
| `site` | character | Unique study site identifier, matching `site` in the other files | — |
| `design` | character | Study design the observation belongs to | — |
| `area` | character | Abbreviation of the study area | — |
| `treatment` | character | Experimental treatment applied to the plot | high_LDMC = species with the highest LDMC removed; tall = the tallest species removed; low_LDMC = species with the lowest LDMC removed; random = random subset of species removed; short = the shortest species removed |
| `date` | date | Date of leaf sample collection | YYYY-MM-DD |
| `year` | numeric | Year of sample collection | — |
| `Lat` | numeric | Latitude of the observation in decimal degrees (WGS84) | — |
| `Lon` | numeric | Longitude of the observation in decimal degrees (WGS84) | — |
| `country` | character | Country where the observation was made | FIN = Finland; NOR = Norway; SWE = Sweden |
| `taxon` | character | Taxon name as used in the dataset (may be subspecies, species, genus, or family) | — |
| `reproduction` | numeric | Sexual reproductive effort index of the species at site at year of sampling | — |
| `leaf_area` | numeric | One-sided leaf area. 10,580 missing values | cm² |
| `SLA` | numeric | Specific leaf area (leaf area per unit dry mass) | mm² mg⁻¹ |
| `LDMC` | numeric | Leaf dry matter content (dry mass per unit fresh mass) | g g⁻¹ |
| `w_weight` | numeric | Fresh (wet) mass of a leaf | g |
| `d_weight` | numeric | Dry mass of a leaf after drying | g  |
| `BITM` | numeric | Brightness index of upper side of a plant leaves derived from scanned RGB imagery; formula = ((B² + G² + R²) / 3)^0.5 | dimensionless |
| `ExG` | numeric | Excess Green Index of upper side of a plant leaves from scanned RGB imagery; formula = (2G − R − B) | dimensionless |

---

## 3. FennoTraits_species.csv

Species-level lookup table with taxonomy and sampling summary statistics. Contains 386 records across 10 variables.

| Variable | Type | Description | Units / Values |
|---|---|---|---|
| `taxon` | character | Taxon name as used across all dataset files; primary key for joining to the other files | — |
| `species` | character | Accepted species name under the LCVP backbone taxonomy | — |
| `author` | character | Author(s) of the accepted species name | — |
| `genus` | character | Genus | — |
| `family` | character | Family | — |
| `order` | character | Order | — |
| `rank` | character | Taxonomic rank of the taxon entry | sub-species / species / genus / family |
| `n_areas` | numeric | Number of distinct study areas in which the taxon was recorded | — |
| `n_locations` | numeric | Number of distinct plot locations at which the taxon was recorded | — |
| `n_leaf_samples` | numeric | Number of individual leaf trait measurements available for the taxon | — |

---

## Notes

- **Joining files:** All three files share the `taxon` column, which serves as the common key.
- **Missing values:** All missing values are encoded as `NA`.
- **Coordinate reference system:** All geographic coordinates (`Lat`, `Lon`) are in decimal degrees, WGS84 (EPSG:4326).
- **Taxonomy:** Species taxonomy follows the Leipzig Catalogue of Vascular Plants (LCVP). Taxon entries at genus or family level (where species identification was not possible) are included in all files and flagged by `rank` in `FennoTraits_species.csv`.

