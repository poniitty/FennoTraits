# FennoTraits
The up-to-date version of FennoTraits dataset.

**Authors:** Pekka Niittynen [<img src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" alt="ORCID iD">](https://orcid.org/0000-0002-7290-029X) & Julia Kemppinen [<img src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" alt="ORCID iD">](https://orcid.org/0000-0001-7521-7229)


We present here FennoTraits, a dataset of plant functional trait and community composition data collected from Fennoscandia across northern Finland, Norway, and Sweden in 2016–2026. The dataset has 44 600 abundance estimations and 166 348 site-level functional trait observations from 10 traits, representing 374 vascular plant species collected from 1283 study sites within seven study areas. The trait measurements consist of size-structural, leaf economic, leaf spectral, and reproductive traits. The species represent the majority of the native vascular plant species that occur in the seven study areas, and many of the species occur in all seven areas across two biomes and their ecotone: tundra and boreal forests. Each study area has distinct characteristics and a range of habitats: tundra, meadows, wetlands, shrublands, and boreal forests. The areas are under low anthropogenic influence, and many of the sites are within protected areas reserved for nature conservation and scientific research. With the dataset, we also provide a general description of the main trait patterns and profiles of the northern European flora.

![**FennoTraits graphical abstract: Sampling protocol and the different plot structures.**](plots/fig1%20v2.png)

**Figure 1.** FennoTraits graphical abstract: Sampling protocol and the different plot structures.

---

**Table 1.** Key statistics of the seven study areas. n trait obs = number of unique trait observations; n species = number of unique species in data; n sites = number of unique study sites with full plant community surveyed

| Area (acronym) | Lat, Lon | Size (km²) | Elevation (m a.s.l.) | Sampling years | n trait obs. | n abundance obs. | n species | n sites |
|---|---|---:|---|---|---:|---:|---:|---:|
| Máttavárri (MAT) | 70.3, 29.1 | 50 | 196–468 | 2023 | 4649 | 1358 | 126 | 49 |
| Rásttigáisa (RAS) | 70.0, 26.3 | 6 | 420–761 | 2023 | 1988 | – | 47 | – |
| Kilpisjärvi (KIL) | 69.1, 20.8 | 160 | 477–1407 | 2016–2026 | 141 354 | 37 623 | 307 | 819 |
| Pallas (PAL) | 68.0, 24.1 | 35 | 268–558 | 2024 | 1365 | – | 54 | – |
| Värriö (VAR) | 67.7, 29.6 | 30 | 262–475 | 2021 | 3785 | 1273 | 87 | 47 |
| Oulanka (OUL) | 66.4, 29.3 | 100 | 143–384 | 2023–2025 | 10 864 | 3891 | 200 | 103 |
| Vindelfjällen (VIN) | 65.8, 15.2 | 14 | 931–1408 | 2021–2023 | 2343 | 455 | 73 | 43 |


---

## Updates

### v2.0.0

- **Improved leaf area estimates.** Leaves in the scanned images are now segmented with a convolutional neural network (CNN, U-Net) instead of the earlier threshold-based method. The CNN separates leaves more reliably from shadows and other non-leaf parts of the scans, which improves the leaf area estimates.
- **New data from summer 2026.** The dataset now includes data collected in summer 2026.

---

## How to cite

If you use FennoTraits, please cite both the data paper and the dataset version you used. We encourage contact from users for guidance, advice, and collaboration. We appreciate users contacting us before visiting the study sites because of our long-term monitoring programs.

**Data paper**

Niittynen, P. & Kemppinen, J. (2026). FennoTraits: dataset of plant functional traits and community composition in northern European flora. *Nordic Journal of Botany*, e05258. https://doi.org/10.1002/njb.05258

**Dataset**

Niittynen, P. & Kemppinen, J. (2026). poniitty/FennoTraits: FennoTraits v2.0.0 (Version v2.0.0). Zenodo. https://doi.org/10.5281/zenodo.22945414

<details>
<summary>BibTeX</summary>

```bibtex
@article{niittynen2026fennotraits,
  author  = {Niittynen, Pekka and Kemppinen, Julia},
  title   = {FennoTraits: dataset of plant functional traits and community composition in northern European flora},
  journal = {Nordic Journal of Botany},
  year    = {2026},
  pages   = {e05258},
  doi     = {10.1002/njb.05258}
}

@misc{niittynen2026fennotraits_v2,
  author    = {Niittynen, Pekka and Kemppinen, Julia},
  title     = {poniitty/FennoTraits: FennoTraits v2.0.0},
  year      = {2026},
  publisher = {Zenodo},
  version   = {v2.0.0},
  doi       = {10.5281/zenodo.22945414}
}
```

</details>

---

# FennoTraits Data Dictionary

Here we describe the variables in the three data files accompanying the FennoTraits dataset.

---

## 1. FennoTraits_community_heights.csv

**Table 2.** Community-level vegetation height and cover data. Contains 45 057 rows across 15 variables.

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
| `cvr` | numeric | Percentage cover of the taxon in the plot | % |
| `median_height` | numeric | Median vegetation height of the taxon in the plot | cm |
| `max_height` | numeric | Maximum vegetation height of the taxon in the plot | cm |

---

## 2. FennoTraits_leaf_traits.csv

**Table 3.** Individual leaf-level functional trait measurements. Contains 24 248 rows across 18 variables.

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
| `n_inds` | numeric | Number of individuals sampled (and pooled) for leaf traits | — |
| `n_leaf` | numeric | Total (sum) of leaves sampled, pooled and processed for leaf traits | — |
| `leaf_area` | numeric | One-sided leaf area | cm² |
| `SLA` | numeric | Specific leaf area (leaf area per unit dry mass) | mm² mg⁻¹ |
| `LDMC` | numeric | Leaf dry matter content (dry mass per unit fresh mass) | g g⁻¹ |
| `w_weight` | numeric | Fresh (wet) mass of a leaf | g |
| `d_weight` | numeric | Dry mass of a leaf after drying | g  |
| `BITM` | numeric | Brightness index of upper side of a plant leaves derived from scanned RGB imagery; formula = ((B² + G² + R²) / 3)^0.5 | dimensionless |
| `ExG` | numeric | Excess Green Index of upper side of a plant leaves from scanned RGB imagery; formula = (2G − R − B) | dimensionless |

---

## 3. FennoTraits_species.csv

**Table 4.** Species-level lookup table with taxonomy and sampling summary statistics. Contains 400 rows across 10 variables.

| Variable | Type | Description | Units / Values |
|---|---|---|---|
| `taxon` | character | Taxon name as used across all dataset files; primary key for joining to the other files | — |
| `species` | character | Accepted species name under the LCVP backbone taxonomy | — |
| `author` | character | Author(s) of the accepted species name | — |
| `genus` | character | Genus | — |
| `family` | character | Family | — |
| `order` | character | Order | — |
| `rank` | character | Taxonomic rank of the taxon entry | sub-species / species / genus / family / hybrid |
| `n_areas` | numeric | Number of distinct study areas in which the taxon was recorded | — |
| `n_locations` | numeric | Number of distinct plot locations at which the taxon was recorded | — |
| `n_leaf_samples` | numeric | Number of individual leaf trait measurements available for the taxon | — |

---

## Notes

- **Joining files:** All three files share the `taxon` column, which serves as the common key. See a usage example in R script `combine_data.R`.
- **Missing values:** All missing values are encoded as `NA`.
- **Coordinate reference system:** All geographic coordinates (`Lat`, `Lon`) are in decimal degrees, WGS84 (EPSG:4326).
- **Taxonomy:** Species taxonomy follows the Leipzig Catalogue of Vascular Plants (LCVP). Taxon entries at genus or family level (where species identification was not possible) are included in all files and flagged by `rank` in `FennoTraits_species.csv`.
