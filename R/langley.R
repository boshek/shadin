## Package
library(raster)
library(rayshader)
library(bcmaps)

## Map originally from: ftp://ftp.geogratis.gc.ca/pub/nrcan_rncan/raster/canmatrix2/125k_tif/092g/canmatrix2_092g_se_tif.zip

## georeference instructions here:
## https://www.qgistutorials.com/en/docs/3/georeferencing_basics.html

## Read in canmatrix
canmatrix <- stack("data/canmatrix2/092G_SW_01_modified.tif")

canmatrix_array <- as.array(canmatrix)/255

## Make neatlines edge
neatlines_edge <- c(-123, -122, 49, 49.5)


## Bring in the dem
dem <- cded_raster(aoi = canmatrix)

## crop elevation
elevation <- crop(dem, extent(canmatrix))

## Create the "lower area"
base_raster <- elevation * 0 - 250
map_elevation <- crop(elevation, extent(neatlines_edge))
elevation <- merge(map_elevation, base_raster)


## Convert into matrix
cded_mat <- raster_to_matrix(elevation)

## Rayshade
ray_shadow <- ray_shade(cded_mat, sunaltitude = 40, sunangle = 90, zscale = 2, multicore = TRUE)
ambient_shadow <- ambient_shade(elev_mat, zscale = 2)


png("out/langley.png", height = nrow(topo_map)/2, width = ncol(topo_map)/2)
topo_rgb_array %>%
  add_shadow(ray_shadow, 0.4) %>%
  add_shadow(ambient_shadow, 0) %>%
  plot_map()
dev.off()
