import geopandas as gpd
import numpy as np
import pandas as pd
from typing import List


us_state_to_abbrev = {
    "Alabama": "AL",
    "Alaska": "AK",
    "Arizona": "AZ",
    "Arkansas": "AR",
    "California": "CA",
    "Colorado": "CO",
    "Connecticut": "CT",
    "Delaware": "DE",
    "Florida": "FL",
    "Georgia": "GA",
    "Hawaii": "HI",
    "Idaho": "ID",
    "Illinois": "IL",
    "Indiana": "IN",
    "Iowa": "IA",
    "Kansas": "KS",
    "Kentucky": "KY",
    "Louisiana": "LA",
    "Maine": "ME",
    "Maryland": "MD",
    "Massachusetts": "MA",
    "Michigan": "MI",
    "Minnesota": "MN",
    "Mississippi": "MS",
    "Missouri": "MO",
    "Montana": "MT",
    "Nebraska": "NE",
    "Nevada": "NV",
    "New Hampshire": "NH",
    "New Jersey": "NJ",
    "New Mexico": "NM",
    "New York": "NY",
    "North Carolina": "NC",
    "North Dakota": "ND",
    "Ohio": "OH",
    "Oklahoma": "OK",
    "Oregon": "OR",
    "Pennsylvania": "PA",
    "Rhode Island": "RI",
    "South Carolina": "SC",
    "South Dakota": "SD",
    "Tennessee": "TN",
    "Texas": "TX",
    "Utah": "UT",
    "Vermont": "VT",
    "Virginia": "VA",
    "Washington": "WA",
    "West Virginia": "WV",
    "Wisconsin": "WI",
    "Wyoming": "WY",
    "District of Columbia": "DC",
    "American Samoa": "AS",
    "Guam": "GU",
    "Northern Mariana Islands": "MP",
    "Puerto Rico": "PR",
    "United States Minor Outlying Islands": "UM",
    "U.S. Virgin Islands": "VI",
}

us_abbrev_to_state = {v: k for k, v in us_state_to_abbrev.items()}


files = [
	# 'CoC_GIS_National_Boundary_2022',
	# 'HUD_2007-2022-PIT-Counts-by-CoC.xlsx',
	# 'tl_2022_us_county',
	'data/bea_gdp_by_county_2018.csv',
	'data/bls_unemployment_by_county_2018.csv',
	'data/census_income_by_county_2018.csv',
	'data/opportunity_insights_social_capital_by_county_2018.csv',
	'data/zillow_zhvi_all_homes_by_county_2018.csv',
	'data/zillow_zhvi_bottom_tier_by_county_2018.csv',
	'data/zillow_zori_rent_by_county_2018.csv',
]


def load_shapes():
	# Load CoC shapefile
	coc_shapefile_path = 'data/CoC_GIS_National_Boundary_2022/CoC_GIS_National_Boundary.gdb'
	coc_gdf = gpd.read_file(coc_shapefile_path)
	# Load county shapefile
	county_shapefile_path = 'data/tl_2022_us_county/tl_2022_us_county.shp'
	county_gdf = gpd.read_file(county_shapefile_path)
	# Make sure both GeoDataFrames have the same CRS (Coordinate Reference System)
	county_gdf = county_gdf.to_crs(coc_gdf.crs)
	# Perform spatial join between CoCs and counties
	coc_county_gdf = gpd.sjoin(county_gdf, coc_gdf, how='inner', op='intersects', lsuffix='cnty', rsuffix='coc')
	coc_county_gdf.columns = coc_county_gdf.columns.str.lower()
	coc_county_gdf['county_name'] = coc_county_gdf['name']
	coc_county_gdf['coc_number'] = coc_county_gdf['cocnum']
	coc_county_gdf['coc_name'] = coc_county_gdf['cocname']
	coc_county_gdf = coc_county_gdf.drop(columns=['cocnum', 'cocname', 'name'])
	return coc_county_gdf[['coc_name', 'coc_number', 'county_name', 'state_name']]


def load_coc(filename: str) -> pd.DataFrame:
	coc_df = pd.read_csv(filename)
	coc_df.columns = [
		col.lower()
			.replace(' - ', '_')
			.replace(' ', '_')
			.replace('/', '_')
			.removesuffix(',_2018')
			.replace('-', '_to_')
			.replace('(', '')
			.replace(')', '')
		for col in coc_df.columns
	]
	return coc_df


def load_bls_unemployment_data(filename: str) -> pd.DataFrame:
	df = pd.read_csv(filename)
	ddf = df['county_name_state_abbreviation'].str.split(', ', expand=True)
	df = df.assign(
		county_name=ddf[0].str.removesuffix(' County'),
		state_name=ddf[1].map(us_abbrev_to_state),
	)
	df = df[[
		'state_name', 'county_name', 'labor_force',
		'employed', 'unemployed', 'unemployment_rate_percent'
	]]
	return df


def load_census_income_data(filename: str) -> pd.DataFrame:
	df = pd.read_csv(filename)
	ddf = df['Geographic Area Name'].str.split(', ', expand=True)
	df = df.assign(
		county_name=ddf[0].str.removesuffix(' County'),
		state_name=ddf[1],
		income_quintile1_estimate=df['Estimate!!Quintile Upper Limits!!Lowest Quintile'],
		income_quintile1_error_margin=df['Margin of Error!!Quintile Upper Limits!!Lowest Quintile'],
		income_quintile2_estimate=df['Estimate!!Quintile Upper Limits!!Second Quintile'],
		income_quintile2_error_margin=df['Margin of Error!!Quintile Upper Limits!!Second Quintile'],
		income_quintile3_estimate=df['Estimate!!Quintile Upper Limits!!Third Quintile'],
		income_quintile3_error_margin=df['Margin of Error!!Quintile Upper Limits!!Third Quintile'],
		income_quintile4_estimate=df['Estimate!!Quintile Upper Limits!!Fourth Quintile'],
		income_quintile4_error_margin=df['Margin of Error!!Quintile Upper Limits!!Fourth Quintile'],
		income_quintile5_estimate=df['Estimate!!Lower Limit of Top 5 Percent'],
		income_quintile5_error_margin=df['Margin of Error!!Lower Limit of Top 5 Percent'],
	)
	df = df[[
		'state_name', 'county_name',
		'income_quintile1_estimate', 'income_quintile1_error_margin',
		'income_quintile2_estimate', 'income_quintile2_error_margin',
		'income_quintile3_estimate', 'income_quintile3_error_margin',
		'income_quintile4_estimate', 'income_quintile4_error_margin',
		'income_quintile5_estimate', 'income_quintile5_error_margin',
	]]
	return df


def load_bea_data(filename: str, data_col: str) -> pd.DataFrame:
	df = pd.read_csv(filename)
	rows = []
	df['is_state'] = False
	df['county_name'] = df['state_or_county']
	is_state = False
	for i, row in df.iterrows():
		if is_state:
			row.is_state = True
			is_state = False
		if (type(row[data_col]) is float
			and np.isnan(row[data_col])):
			state_name = df.loc[i+1, 'state_or_county']
			is_state = True
		else:
			row['state_name'] = state_name
			try:
				row[data_col] = float(row[data_col].replace(',', ''))
			except ValueError:
				row[data_col] = np.nan
		rows.append(row)
	parsed_df = pd.DataFrame(rows)
	parsed_df = parsed_df.dropna()
	parsed_df = parsed_df[parsed_df['is_state'] == False]
	parsed_df = parsed_df.drop(columns=['is_state', 'state_or_county'])
	parsed_df = parsed_df[[
		'state_name', 'county_name', data_col]]
	return parsed_df


def load_bea_income_data(filename: str) -> pd.DataFrame:
	return load_bea_data(filename, 'mean_income_2018')


def load_bea_gdp_data(filename: str) -> pd.DataFrame:
	return load_bea_data(filename, 'real_gdp_2012_dollars_2018')


def load_opportunity_insights_social_capital_data(filename: str) -> pd.DataFrame:
	df = pd.read_csv(filename)
	ddf = df['county_name'].str.split(', ', expand=True)
	df = df.assign(
		county_name=ddf[0],
		state_name=ddf[1],
	)
	df = df[[
		'state_name', 'county_name',
		'num_below_p50', 'pop2018', 'ec_county', 'ec_se_county',
		'child_ec_county', 'child_ec_se_county', 'ec_grp_mem_county',
		'ec_high_county', 'ec_high_se_county', 'child_high_ec_county',
		'child_high_ec_se_county', 'ec_grp_mem_high_county',
		'exposure_grp_mem_county', 'exposure_grp_mem_high_county',
		'child_exposure_county', 'child_high_exposure_county',
		'bias_grp_mem_county', 'bias_grp_mem_high_county', 'child_bias_county',
		'child_high_bias_county', 'clustering_county', 'support_ratio_county',
		'volunteering_rate_county', 'civic_organizations_county',
	]]
	return df


def load_zillow_housing_price_data(index: str, filename: str) -> pd.DataFrame:
	df = pd.read_csv(filename)
	df['county_name'] = df['region_name'].str.removesuffix(' County')
	df['state_name'] = df['state_name'].map(us_abbrev_to_state)
	df[f'{index}_value'] = df[[v for v in df.columns if v.startswith('2018-')]].sum(axis=1)
	df = df[['state_name', 'county_name', f'{index}_value']]
	return df


# def load_coc_to_county_df() -> pd.DataFrame:
# 	# df = load_shapes()
# 	df = pd.read_csv('data/coc_to_county.csv').sort_values(by=['coc_number', 'state_name', 'county_name'])
# 	df = df.drop_duplicates()
# 	df = df[~df[['state_name', 'county_name']].duplicated(keep=False)]
# 	# df = df[~df['coc_name'].str.contains('Balance of State')]
# 	# df.to_csv('data/coc_to_county.csv', index=False)
# 	return df

def load_coc_to_county_df() -> pd.DataFrame:
	fips_to_county_df = pd.read_csv('data/fips2county.tsv', sep='\t')
	fips_to_county_df = fips_to_county_df.rename(columns={
	    'StateFIPS': 'state_fips',
	    'StateName': 'state_name',
	    'CountyName': 'county_name',
	    'CountyFIPS': 'county_fips',
	})
	fips_to_county_df = fips_to_county_df[['state_fips', 'state_name', 'county_name', 'county_fips']]
	fips_to_county_df

	coc_mapping_df = pd.read_csv('data/county_coc_match.csv')
	coc_mapping_df = coc_mapping_df[coc_mapping_df['rel_type'] != 4.0].groupby(['coc_name', 'coc_number', 'county_fips']).count().reset_index()
	coc_mapping_df = coc_mapping_df[['coc_name', 'coc_number', 'county_fips']]
	coc_mapping_df

	coc_mapping_df = coc_mapping_df.merge(fips_to_county_df, on=['county_fips'], how='inner')
	return coc_mapping_df


def merge_dfs(dfs: List[pd.DataFrame], cols: List[str]) -> pd.DataFrame:
	merged_df = dfs[0]
	for i, df in enumerate(dfs[1:]):
		merged_df = merged_df.merge(df, on=cols, how='inner')
		print(i, len(merged_df))
	return merged_df


def main():
	unemployment_df = load_bls_unemployment_data('data/bls_unemployment_by_county_2018.csv')
	income_df = load_bea_income_data('data/bea_income_by_county_2018.csv')
	gdp_df = load_bea_gdp_data('data/bea_gdp_by_county_2018.csv')
	social_capital_df = load_opportunity_insights_social_capital_data('data/opportunity_insights_social_capital_by_county_2018.csv')
	all_homes_df = load_zillow_housing_price_data('zhvi_all_homes', 'data/zillow_zhvi_all_homes_by_county_2018.csv')
	bottom_tier_homes_df = load_zillow_housing_price_data('zhvi_bottom_tier', 'data/zillow_zhvi_bottom_tier_by_county_2018.csv')
	rent_df = load_zillow_housing_price_data('zori', 'data/zillow_zori_rent_by_county_2018.csv')

	coc_to_county_df = load_coc_to_county_df()
	dfs = [
		unemployment_df,
		income_df,
		gdp_df,
		social_capital_df,
		all_homes_df,
		bottom_tier_homes_df,
		rent_df,
		coc_to_county_df,
	]

	merged_df = merge_dfs(dfs, ['state_name', 'county_name'])
	coc_df = load_coc('data/hud_2018_pit_counts_by_coc.csv')
	coc_data_cols = [col for col in coc_df.columns if col not in ['coc_name', 'coc_number']]
	merged_df = merged_df.merge(coc_df, on=['coc_number', 'coc_name'])
	merged_df = merged_df.sort_values(by=['coc_number', 'coc_name', 'state_name', 'county_name']).reset_index(drop=True)

	mean_cols = [
		'mean_income_2018',
		'ec_county',
		'child_ec_county',
		'ec_grp_mem_county',
		'ec_high_county',
		'child_high_ec_county',
		'ec_grp_mem_high_county',
		'exposure_grp_mem_county',
		'exposure_grp_mem_high_county',
		'child_exposure_county',
		'child_high_exposure_county',
		'bias_grp_mem_county',
		'bias_grp_mem_high_county',
		'child_bias_county',
		'child_high_bias_county',
		'clustering_county',
		'support_ratio_county',
		'volunteering_rate_county',
		'civic_organizations_county',
		'zhvi_bottom_tier_value',
		'zori_value',
	]
	total_mean_cols = [f'total_{col}' for col in mean_cols]
	new_mean_cols = [f'mean_{col}' for col in total_mean_cols]
	merged_df[total_mean_cols] = merged_df[mean_cols].multiply(merged_df['pop2018'], axis=0)

	sum_cols = [
		'labor_force', 'employed', 'unemployed',
		'real_gdp_2012_dollars_2018', 'num_below_p50', 'pop2018',
		'zhvi_all_homes_value',
	]
	per_capita_cols = [f'per_capita_{col}' for col in sum_cols]

	# import pprint
	# pprint.pprint(list(merged_df.columns))
	grouped_by_df = merged_df.groupby(['coc_number', 'coc_name'])
	df1 = grouped_by_df[coc_data_cols].mean().reset_index()
	df2 = grouped_by_df[sum_cols + total_mean_cols].sum().reset_index()
	df2[new_mean_cols] = df2[total_mean_cols].div(df2['pop2018'], axis=0)
	df2[per_capita_cols] = df2[sum_cols].div(df2['pop2018'], axis=0)
	df = df1.merge(df2, on=['coc_number', 'coc_name'])
	df = df.drop(columns=mean_cols + total_mean_cols + sum_cols, errors='ignore')
	df.to_csv('data/project_dataset.csv', index=False)
	# import pdb; pdb.set_trace()


if __name__ == '__main__':
	main()
