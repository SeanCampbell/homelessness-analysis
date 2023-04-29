import geopandas as gpd

# Load CoC shapefile
coc_shapefile_path = "data/CoC_GIS_National_Boundary_2022/CoC_GIS_National_Boundary.gdb"
coc_gdf = gpd.read_file(coc_shapefile_path)

# Load county shapefile
county_shapefile_path = "data/tl_2022_us_county/tl_2022_us_county.shp"
county_gdf = gpd.read_file(county_shapefile_path)

# Make sure both GeoDataFrames have the same CRS (Coordinate Reference System)
county_gdf = county_gdf.to_crs(coc_gdf.crs)

# Perform spatial join between CoCs and counties
coc_county_gdf = gpd.sjoin(county_gdf, coc_gdf, how='inner', op='intersects', lsuffix='cnty', rsuffix='coc')

coc_county_gdf[['STATE_NAME', 'COUNTYFP', 'COUNTYNS', 'NAME', 'NAMELSAD', 'COCNAME']][:10]


# Keep only relevant columns
# coc_county_gdf = coc_county_gdf[['GEOID_cnty', 'NAME_cnty', 'STATE_NAME', 'GEOID_coc', 'COCNAME', 'geometry']]

# Rename columns for clarity
# coc_county_gdf.columns = ['County_GEOID', 'County_Name', 'State_Name', 'CoC_GEOID', 'CoC_Name', 'geometry']

# Save the resulting GeoDataFrame as a shapefile
# output_shapefile_path = "path/to/output/CoC_county_shapefile.shp"
# coc_county_gdf.to_file(output_shapefile_path)

# Save the resulting GeoDataFrame as a CSV (excluding geometry)
# output_csv_path = "path/to/output/CoC_county_data.csv"
# coc_county_gdf[['County_GEOID', 'County_Name', 'State_Name', 'CoC_GEOID', 'CoC_Name']].to_csv(output_csv_path, index=False)


# import geopandas
# import pandas as pd
#
#
# def main():
# 	pass
#
#
# if __name__ == '__main__':
# 	main()
