import delimited "/Users/Sean/Documents/School/Grad School/[6910] Applied Econometrics/Research Project/Code/data/project_dataset.csv", clear

gen homeless_pc = overall_homeless / pop2018
gen homeless_black_pc = overall_homeless_black / pop2018
gen homeless_white_pc = overall_homeless_white / pop2018
gen employed_pc = employed / pop2018
gen unemployment_rate = unemployed / labor_force

reg homeless_pc employed_pc zhvi_all_homes_value, r

gen l_zhvi_all_homes_value = log(zhvi_all_homes_value)

gen l_real_gdp_2012_dollars_2018 = log(real_gdp_2012_dollars_2018)
gen gdp_pc = real_gdp_2012_dollars_2018 / pop2018
gen l_gdp_pc = log(real_gdp_2012_dollars_2018 / pop2018)
gen income_pc = mean_income_2018
gen l_income_pc = log(mean_income_2018)

gen l_pop = log(pop2018)

reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county, r


reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_real_gdp_2012_dollars_2018, r

reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_real_gdp_2012_dollars_2018 l_pop, r


reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_gdp_pc, r

reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_income_pc, r

reg homeless_black_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_income_pc, r

reg homeless_white_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_income_pc, r
