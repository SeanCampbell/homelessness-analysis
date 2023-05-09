import delimited "/Users/Sean/Documents/School/Grad School/[6910] Applied Econometrics/Research Project/Code/homelessness-analysis/data/model/model_dataset_by_county_2012_to_2020_no_4_rel_type.csv", clear

import delimited "/Users/Sean/Documents/School/Grad School/[6910] Applied Econometrics/Research Project/Code/homelessness-analysis/data/model/model_dataset_by_county_2012_to_2020_no_3_or_4_rel_type.csv", clear


// Line plot of total homelessness per year
collapse (sum)overall_homeless (sum)sheltered_total_homeless (sum)unsheltered_homeless, by(year)
label var overall_homeless "Total Homeless"
label var sheltered_total_homeless "Sheltered Homeless"
label var unsheltered_homeless "Unsheltered Homeless"
line overall_homeless sheltered_total_homeless unsheltered_homeless year

label var overall_homeless "Total Homeless"
label var sheltered_total_homeless "Sheltered Homeless"
label var unsheltered_homeless "Unsheltered Homeless"
label var unemployment_rate "Unemployment Rate"
label var zhvi_all_homes_value "Home Price Index - All Homes"
label var zhvi_bottom_tier_value "Home Price Index - Bottom Tier Homes"
label var mean_annual_temperature "Mean Annual Temperature"
label var per_capita_income "Per Capita Income"
label var affordable_units_total "Affordable Units - Total"
label var affordable_units_vacant "Affordable Units - Vacant"
label var affordable_units_occupied "Affordable Units - Occupied"

gen homeless_per_100000 = overall_homeless / population * 100000
label var homeless_per_100000 "Homeless per 100,000"
gen sheltered_homeless_per_100000 = sheltered_total_homeless / population * 100000
label var sheltered_homeless_per_100000 "Sheltered homeless per 100,000"
gen unsheltered_homeless_per_100000 = unsheltered_homeless / population * 100000
label var unsheltered_homeless_per_100000 "Unsheltered homeless per 100,000"
gen chronically_homeless_per_100000 = chronically_homeless / population * 100000
label var chronically_homeless_per_100000 "Chronically homeless per 100,000"

gen poverty_rate = poverty / population
gen affordable_units_vacant_pc = affordable_units_vacant / population
gen affordable_units_total_pc = affordable_units_total / population
gen employed_pc = employed / population
gen unemployment_rate = unemployed / labor_force
gen lfpr = labor_force / population
gen l_zhvi_all_homes_value = log(zhvi_all_homes_value)
label var l_zhvi_all_homes_value "ZHVI all housing index (log)"
gen l_zhvi_bottom_tier_value = log(zhvi_bottom_tier_value)
label var l_zhvi_bottom_tier_value "ZHVI bottom tier housing index (log)"
gen l_population = log(population)
gen l_income_pc = log(per_capita_income)
label var l_income_pc "Income per capita (log)"
gen l_pop = log(population)

egen mean_annual_temperature_std = std(mean_annual_temperature)

gen income_housing_ratio = per_capita_income / zhvi_all_homes_value
gen l_inc_housing_ratio = log(income_housing_ratio)
gen income_bottom_tier_housing_ratio = per_capita_income / zhvi_bottom_tier_value
gen l_inc_bottom_tier_housing_ratio = log(income_bottom_tier_housing_ratio)



encode coc_name, gen(coc_enc)
xtset coc_enc year

drop if year < 2014
drop if year == 2021

encode state_name, gen(state_enc)
xtset state_enc year


xtreg homeless_pc l_income_pc unemployment_rate l_zhvi_bottom_tier_value mean_annual_temperature_std affordable_units_total_pc i.year l_pop, r

xtreg homeless_pc l_income_pc unemployment_rate l_zhvi_bottom_tier_value mean_annual_temperature affordable_units_total_pc i.year, r

xtreg homeless_pc l_income_pc unemployment_rate l_zhvi_bottom_tier_value mean_annual_temperature affordable_units_total_pc l_population i.year, r


xtreg homeless_pc l_income_pc unemployment_rate l_zhvi_all_homes_value mean_annual_temperature i.year, r

hist homeless_per_10000, bin(20) xlabel(#20, angle(315))

reg homeless_pc employed_pc zhvi_all_homes_value, r


reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county, r


reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_real_gdp_2012_dollars_2018, r

reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_real_gdp_2012_dollars_2018 l_pop, r


reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_gdp_pc, r

reg homeless_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_income_pc, r

reg homeless_black_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_income_pc, r

reg homeless_white_pc employed_pc l_zhvi_all_homes_value civic_organizations_county l_income_pc, r




 
hist overall_homeless
hist sheltered_total_homeless
hist unsheltered_homeless
hist unemployment_rate
hist zhvi_all_homes_value
hist zhvi_bottom_tier_value
hist mean_annual_temperature
hist per_capita_income
hist affordable_units_total
hist affordable_units_vacant
hist affordable_units_occupied



xtreg homeless_per_100000 unemployment_rate mean_annual_temperature_std affordable_units_total_pc l_income_pc l_zhvi_bottom_tier_value  i.year, r


xtreg homeless_per_100000 unemployment_rate mean_annual_temperature_std affordable_units_total_pc l_income_pc l_zhvi_all_homes_value i.year, r


xtreg homeless_per_100000 unemployment_rate mean_annual_temperature_std affordable_units_total_pc l_inc_housing_ratio i.year, r




xtreg homeless_pc l_income_pc unemployment_rate l_zhvi_bottom_tier_value mean_annual_temperature_std affordable_units_total_pc i.year, r

// Random-effects GLS regression                   Number of obs     =      2,380
// Group variable: coc_enc                         Number of groups  =        342
//
// R-squared:                                      Obs per group:
//      Within  = 0.0391                                         min =          5
//      Between = 0.0801                                         avg =        7.0
//      Overall = 0.0740                                         max =          7
//
//                                                 Wald chi2(11)     =      75.91
// corr(u_i, X) = 0 (assumed)                      Prob > chi2       =     0.0000
//
//                                              (Std. err. adjusted for 342 clusters in coc_enc)
// ---------------------------------------------------------------------------------------------
//                             |               Robust
//                 homeless_pc | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// ----------------------------+----------------------------------------------------------------
//                 l_income_pc |   .0006567   .0006088     1.08   0.281    -.0005366    .0018499
//           unemployment_rate |    .001014   .0034349     0.30   0.768    -.0057183    .0077463
//    l_zhvi_bottom_tier_value |   .0004524   .0002236     2.02   0.043     .0000142    .0008907
// mean_annual_temperature_std |   .0003671   .0001253     2.93   0.003     .0001214    .0006128
//   affordable_units_total_pc |   .0097702   .0046623     2.10   0.036     .0006321    .0189082
//                             |
//                        year |
//                       2015  |  -.0002291   .0000488    -4.69   0.000    -.0003248   -.0001334
//                       2016  |  -.0003692   .0000619    -5.96   0.000    -.0004905   -.0002478
//                       2017  |  -.0006245   .0001125    -5.55   0.000     -.000845   -.0004041
//                       2018  |  -.0006406   .0001219    -5.25   0.000    -.0008795   -.0004016
//                       2019  |  -.0007109   .0001359    -5.23   0.000    -.0009773   -.0004446
//                       2020  |  -.0008302   .0001714    -4.84   0.000    -.0011662   -.0004942
//                             |
//                       _cons |  -.0101444   .0051157    -1.98   0.047     -.020171   -.0001177
// ----------------------------+----------------------------------------------------------------
//                     sigma_u |  .00192055
//                     sigma_e |  .00059755
//                         rho |  .91173951   (fraction of variance due to u_i)
// ---------------------------------------------------------------------------------------------


xtreg homeless_pc l_income_pc unemployment_rate l_zhvi_bottom_tier_value mean_annual_temperature_std affordable_units_vacant_pc i.year, r

// Random-effects GLS regression                   Number of obs     =      2,380
// Group variable: coc_enc                         Number of groups  =        342
//
// R-squared:                                      Obs per group:
//      Within  = 0.0356                                         min =          5
//      Between = 0.0758                                         avg =        7.0
//      Overall = 0.0699                                         max =          7
//
//                                                 Wald chi2(11)     =      78.14
// corr(u_i, X) = 0 (assumed)                      Prob > chi2       =     0.0000
//
//                                              (Std. err. adjusted for 342 clusters in coc_enc)
// ---------------------------------------------------------------------------------------------
//                             |               Robust
//                 homeless_pc | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// ----------------------------+----------------------------------------------------------------
//                 l_income_pc |   .0007238   .0006223     1.16   0.245    -.0004959    .0019434
//           unemployment_rate |   .0015306   .0034288     0.45   0.655    -.0051897    .0082509
//    l_zhvi_bottom_tier_value |    .000426   .0002248     1.90   0.058    -.0000145    .0008665
// mean_annual_temperature_std |   .0003582   .0001247     2.87   0.004     .0001137    .0006027
//  affordable_units_vacant_pc |   .0235132   .0365654     0.64   0.520    -.0481537      .09518
//                             |
//                        year |
//                       2015  |  -.0002248   .0000486    -4.63   0.000      -.00032   -.0001296
//                       2016  |  -.0003614   .0000615    -5.88   0.000    -.0004819    -.000241
//                       2017  |  -.0004988   .0000905    -5.51   0.000    -.0006761   -.0003215
//                       2018  |  -.0005153    .000103    -5.00   0.000    -.0007172   -.0003135
//                       2019  |  -.0005856   .0001192    -4.91   0.000    -.0008192   -.0003521
//                       2020  |  -.0007295   .0001782    -4.09   0.000    -.0010787   -.0003802
//                             |
//                       _cons |  -.0105953   .0052661    -2.01   0.044    -.0209167   -.0002739
// ----------------------------+----------------------------------------------------------------
//                     sigma_u |  .00191305
//                     sigma_e |  .00059862
//                         rho |  .91081876   (fraction of variance due to u_i)
// ---------------------------------------------------------------------------------------------
//


xtreg homeless_pc l_income_pc unemployment_rate zhvi_all_homes_value mean_annual_temperature_std affordable_units_total_pc i.year, r

// Random-effects GLS regression                   Number of obs     =      2,384
// Group variable: coc_enc                         Number of groups  =        342
//
// R-squared:                                      Obs per group:
//      Within  = 0.0440                                         min =          5
//      Between = 0.0979                                         avg =        7.0
//      Overall = 0.0935                                         max =          7
//
//                                                 Wald chi2(11)     =      92.54
// corr(u_i, X) = 0 (assumed)                      Prob > chi2       =     0.0000
//
//                                              (Std. err. adjusted for 342 clusters in coc_enc)
// ---------------------------------------------------------------------------------------------
//                             |               Robust
//                 homeless_pc | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// ----------------------------+----------------------------------------------------------------
//                 l_income_pc |  -.0000949   .0006991    -0.14   0.892    -.0014651    .0012754
//           unemployment_rate |  -.0003087   .0034984    -0.09   0.930    -.0071654    .0065479
//        zhvi_all_homes_value |   2.68e-09   1.03e-09     2.59   0.010     6.49e-10    4.70e-09
// mean_annual_temperature_std |   .0003249   .0001344     2.42   0.016     .0000615    .0005882
//   affordable_units_total_pc |   .0103092   .0046948     2.20   0.028     .0011075    .0195109
//                             |
//                        year |
//                       2015  |  -.0002081   .0000493    -4.22   0.000    -.0003047   -.0001114
//                       2016  |  -.0003386    .000056    -6.05   0.000    -.0004483   -.0002289
//                       2017  |  -.0005807   .0001061    -5.47   0.000    -.0007886   -.0003727
//                       2018  |  -.0005737   .0001148    -5.00   0.000    -.0007988   -.0003487
//                       2019  |  -.0006121   .0001298    -4.72   0.000    -.0008665   -.0003577
//                       2020  |  -.0006244   .0001906    -3.28   0.001    -.0009979   -.0002508
//                             |
//                       _cons |   .0025968   .0073646     0.35   0.724    -.0118375    .0170312
// ----------------------------+----------------------------------------------------------------
//                     sigma_u |   .0019147
//                     sigma_e |    .000596
//                         rho |  .91166473   (fraction of variance due to u_i)
// ---------------------------------------------------------------------------------------------


xtreg homeless_pc l_income_pc unemployment_rate mean_annual_temperature_std affordable_units_total_pc i.year, r



scatter zhvi_all_homes_value zhvi_bottom_tier_value

corr zhvi_all_homes_value zhvi_bottom_tier_value
// (obs=2,384)
//
//              | zhvi_a~e zhvi_b~e
// -------------+------------------
// zhvi_all_h~e |   1.0000
// zhvi_botto~e |   0.9853   1.0000



xtreg homeless_pc income_housing_ratio unemployment_rate mean_annual_temperature_std affordable_units_total_pc i.year, r

// Random-effects GLS regression                   Number of obs     =      2,380
// Group variable: coc_enc                         Number of groups  =        342
//
// R-squared:                                      Obs per group:
//      Within  = 0.0317                                         min =          5
//      Between = 0.0866                                         avg =        7.0
//      Overall = 0.0792                                         max =          7
//
//                                                 Wald chi2(10)     =      60.01
// corr(u_i, X) = 0 (assumed)                      Prob > chi2       =     0.0000
//
//                                              (Std. err. adjusted for 342 clusters in coc_enc)
// ---------------------------------------------------------------------------------------------
//                             |               Robust
//                 homeless_pc | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
// ----------------------------+----------------------------------------------------------------
//        income_housing_ratio |  -.0017522   .0007645    -2.29   0.022    -.0032507   -.0002538
//           unemployment_rate |   .0002585   .0034535     0.07   0.940    -.0065102    .0070272
// mean_annual_temperature_std |   .0003253    .000124     2.62   0.009     .0000822    .0005684
//   affordable_units_total_pc |   .0095132   .0046919     2.03   0.043     .0003173    .0187091
//                             |
//                        year |
//                       2015  |  -.0001819   .0000503    -3.61   0.000    -.0002806   -.0000832
//                       2016  |  -.0002957   .0000629    -4.70   0.000     -.000419   -.0001724
//                       2017  |  -.0004987   .0001058    -4.71   0.000    -.0007061   -.0002913
//                       2018  |   -.000459   .0001127    -4.07   0.000      -.00068    -.000238
//                       2019  |  -.0004774   .0001242    -3.84   0.000    -.0007208    -.000234
//                       2020  |  -.0004772   .0001305    -3.66   0.000     -.000733   -.0002213
//                             |
//                       _cons |    .002566   .0003733     6.87   0.000     .0018345    .0032976
// ----------------------------+----------------------------------------------------------------
//                     sigma_u |  .00188723
//                     sigma_e |  .00059908
//                         rho |  .90845578   (fraction of variance due to u_i)
// ---------------------------------------------------------------------------------------------
//


xtreg homeless_pc l_inc_housing_ratio unemployment_rate mean_annual_temperature_std affordable_units_total_pc i.year, r
