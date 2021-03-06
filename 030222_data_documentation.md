Data Documentation
================
Chong Li
3/2/2022

### Content

-   The information below details the process of transforming ACS
    variables into FRS

#### 1. Residence

-   `state` and `residence`
-   Using the PUMA code that corresponds with the state and county data
-   The reference source is downloaded from
    <https://usa.ipums.org/usa/volii/pumas10.shtml>
-   Note: the county information might be slightly more deatiled than
    needed.

#### 2. Family structure

-   `family_structure`
-   filter for HHT2 = 1, 6, 10, which refers to families with two
    parents (married only), or one father or one mother.
-   Of the total 3641854 households, there are 867,278 households with
    children (married + mother only + father only)
-   If counting families that are cohabiting, then there are 928,588
    households with children - this is the final data.

#### 3. Age of Child

-   `child1_age`, `child2_age`, `child3_age`, `child4_age` and
    `child5_age`
-   The age is selected as the `AGEP` value for all individual entries
    with `RELSHIPP` equals 25, 26 and 27 - which represents “biological
    sons and daugter”, “Adopted sons and daughter”, and “stepson and
    stepdaughter”.

#### 4. Age of parents

-   `parent1_age`, `parent2_age`
-   Given only one parent, then `parent1` is the default
-   Given two parents, `parent1` is set to be the one with higher total
    income. If there is a tie in income, then the female parent would be
    `parent1`.

#### 5. parental disability

-   `disability_parent[x]`
-   the assignment of `parent1` is consistent with previous age of
    parents.
-   1: with disability, 0: without disability

#### 6. children disability

-   `disability_child[x]`
-   similar to parent variables, also consistent with previous children
    age
-   1: with disability, 2: without disability

#### 7. Child support from non-custodial parent

-   `cs_flag`
-   child support data from
    <https://www.census.gov/content/dam/Census/library/publications/2020/demo/p60-269.pdf>
-   For all the families with only 1 parent - 193702 families in total,
    roughly 21% of total households (aligns up with national average)
-   For those families, randomize whether they receive payment or not by
    the ratio of 0.698

#### 8. breastfeeding

-   source: <https://www.cdc.gov/breastfeeding/data/facts.html>
-   randomize across all children with the percentage

#### 9. Parents with non-traditional work hour

-   `nontradtionalwork`
-   as long as at least 1 of the parent works non traditional hour, then
    it is 1 (otherwise 0)
-   nontraditional work hour is defined to be `JWAP` (work arrival time)
    between 6pm to 4am the next day.

### 10. Immigration status of each person in the household

-   `immigration`
-   given that this is household level data, we would only use the
    information for the reference
-   if the household reference is a citizen, then 0. if an immigrant,
    then 1.

#### 11. How many hours does person \[x\] work in a week

-   `parent1_max_work`
-   the variable only captures parent 1, which is decided by income -
    also consistent with previous parent_1s
-   use the `WKHP` variable of the ACS dataframe

#### 12. Up to many hours are in each shift for the person \[x\]

-   `maxshiftlength_parent1`
-   Now because we have no idea how many shifts a person works per week,
    I assume that it’s just 5 shifts per week (5 work days)
-   so the variable here essentially is how many hours per work day.
-   similarly, this variable only covers parent 1.

#### 13. Up to how many days/week does the person \[x\] work

-   `maxworkweek_parent1`
-   `WKWN` - Weeks worked during past 12 months (not used here)
-   for the ones with NA value, the value is set to -9 (which presumably
    are the ones who don’t work)
-   consistent with parent1 in previous columns (tiebreaker: most
    income, head of household, or female)

#### 14. Number of hours of travel time between shifts for person \[x\]

-   `backtobackshifts_parent1`
-   Use the `JWMNP`, divide by 60.
-   Because between shifts data is not indicated in the ACS, this
    variable simply measures the amount of commute time
-   The NA values are also set to -9.

#### 15. Max number of weekend days worked

-   calculated as number of days worked above 5 work days
-   The number of work days is calculated using the hours worked per
    week/8. Here 8 hours is used as a standard work day.
-   `weekenddaysworked` is the variable

#### 16. Number of hours first parent work in a week before the second parent begins

-   `parent1_first_max`
-   The difference between the work arrival time of 1st and 2nd parent.
-   For about half the entries this value is NA. i.e. families with only
    one parent or with only one working parent.

#### 17. Number of hours of travel time between shifts for the second parent

-   `backtobackshifts_parent2`
-   the same as parent1 variable

#### When both parents are working, up to how many hours per week is one parent at home on the WEEKDAYS while the other parent is working or traveling to work?

#### When both parents are working, up to how many hours per week is one parent at home on the WEEKENDS while the other parent is working or traveling to work?

#### 18. What time does person \[x\] start work?

-   `workdaystart`
-   calculated by JWAP, which is the work arrival time

#### Up to how many shifts does parent work/day during weekend

-   this one cannot be inferred from the ACS data

#### 19. What mode of transportion do you use to get to work?

-   `user_trans_type`
-   dictionary: 1 - car, 2- bus, 3-subway, 4-train, 5-long rail, 6-ferry
    boat, 7-taxi boat, 8-motorcycle, 9-bicycle, 10-walked, 11-worked
    from home, 12-other method

#### 20. Amount of family savings

-   `savings`
-   use the median
    <https://www.federalreserve.gov/econres/scf/dataviz/scf/chart/#series:Transaction_Accounts;demographic:all;population:1;units:median>
-   using standard deviation of 1000, median of 5300, generate a normal
    distribution.

#### 21. Value of the family’s first car

-   `vehicle1_value`
-   <https://www.statista.com/statistics/274928/used-vehicle-average-selling-price-in-the-united-states/>
-   randomize the asset value by how many cars there are per household
    `VEH`
-   The SD is selected to be 2000 - which could be subjected to further
    change.

#### 22. Amount family owes on first car

-   `vehicle1_owed`
-   <https://fortunly.com/statistics/car-loan-statistics/#gref>
-   <https://www.bankrate.com/loans/auto-loans/average-monthly-car-payment/>
-   assuming 60% of households financed their car, for those who did,
    the car is at half of the auto loan left.

#### 23. Debt payment

-   Debt payments (credit cards, medical debt, car repayment)
-   <https://www.lendingtree.com/credit-cards/credit-card-debt-statistics/>
    credit cards - 7000 per household
-   medical debt:
    <https://siepr.stanford.edu/news/americas-medical-debt-much-worse-we-think>
    -   18% of total folks have medical debt; average at 2400
-   car repayment: 6000 per year from previous data; 60% households have
    it

#### Annual income of non-custodial parent

#### SPR child care setting

-   `child[x]_nobenefit_setting`
-   CCDF RULES

#### Amount paid for child\[x\] per day

-   `child[x]_nobenefit_amt_m`

#### child care cost estimate

-   `child_care_nobenefit_estimate_source`
-   state pay rate, dollar amount

#### SPR, child\[x\]

-   `child[x]_continue_setting`

#### Amount, child \[x\]

-   `child[x]_continue_amt_m`

#### setting for subsidized child care, child \[x\]

-   `child[x]_withbenefit_setting`

#### does child \[x\] continue in the same setting when ineligible for subsidized care?

-   `child[x]_continue_flag`

#### 24. Health cost estimate source

-   `privateplan_type`
-   First filter for only household reference persons who have private
    insurance through `PRIVCOV`
-   Then determined by variable `HINS1`, which indicates whether a
    person has employer based insurance or individual

#### 25. cost of parents’/family’s health insurance

-   `hlth_costs_parent_m` and `hlth_costs_family_m`
-   Always “0” (because this variable is only used when the user enters
    the health costs or the health costs are available in survey data)

#### 26. cost of out of pocket medical expense

-   `hlth_costs_oop_m`
-   source:
    <https://www.commonwealthfund.org/publications/issue-briefs/2019/may/how-much-us-households-employer-insurance-spend-premiums-out-of-pocket#>:\~:text=across%20the%20South.-,Out%2Dof%2DPocket%20Costs,or%20more%20on%20these%20items.
-   The median household out of pocket expense is 800 dollars according
    to the information. (POSSIBLE ERROR)

#### 27. user-entered plan type

-   `userplantype`
-   Always “employer” (because this is never invoked)

#### 28. amount of the medical expernses related to parent disability

-   `disability_medical_expenses_mnth`
-   <https://www.nationaldisabilityinstitute.org/wp-content/uploads/2020/10/extra-costs-living-with-disability-brief.pdf>
-   according to research oop expense is about twice as high as those
    without disability

#### 29. estimate source of housing & housing expenses

-   `housing_override` and `housing_override_amt`
-   housing costs include both mortgage payment as well as monthly rent
-   `MRGP` and `RNTP`

#### 30. Home type

-   `home_type`
-   use the `BLD` variable from the ACS.
-   For the values that are greater than 4 - apartments; otherwise,
    houses.

#### 31. energy source

-   `fuel_source`
-   derived from the `HFL` variable from ACS
-   utility gas = 1; tank/lp/bottled gas = 2; electricity = 3; fuel
    oil/kerosene = 4; coal = 5; wood = 6; solar = 7; 8 = other fuel; no
    fuel used = 9

#### 32. Estimate cost for Energy

-   `energy cost_override`
-   The sum of all the energy related variables of the ACS data: fuel,
    gas and electricity
-   `GASP` + `FULP`/12 + `WATP`/12 + `ELEP`

#### 33. Estimate cost for food

-   `food_override`
-   source: <https://www.bls.gov/news.release/cesan.nr0.htm>
-   The average household cost of food is 8169, both at home and away
    from home

#### 34. Estimate source for transportation

-   `trans_override`
-   1 if JWTRNS = walking or work from home, 0 if anything else

#### 35. Monthly transportation expenses parents 1 & 2

-   `trans_override_parent1_amt` and `trans_override_parent1_amt`
-   Both are set to “0”, which I am not sure why?
-   Needs to be looked at ocne hook up with the pearl code

#### 36. Estimated monthly cost for other necessities

-   `other_override`
-   here the cost refers to pension and social security
-   source: <https://www.bls.gov/news.release/cesan.nr0.htm>

#### 37. Monthly Additional personal (non-work-related) expenses needed by disabled adult(s) in household

-   `disability_personal_expenses_m`
-   <https://www.nationaldisabilityinstitute.org/wp-content/uploads/2020/10/extra-costs-living-with-disability-brief.pdf>
-   In order to have the same quality of life, disabled people need to
    pay 1466 more than other individuals.

#### Monthly Additional expenses need for items or services needed by disabled parent in order to work

-   `disability_work_expenses_m`

#### 38. 4 mandatory NA flags

-   `disability_flag`, `fosterchild_flag`, `noncitizen_flag`,
    `felony_conviction_flag`
-   Does anybody in the home have a disability?
-   Does the household include any foster children?
-   Is any member of the household a non-citizen?
-   Has any adult living in the household been convicted of a felony?

#### 39. Employment of second parent (if different than 0, 20, or 40, enter that amount below)

-   `parent2_max_work`
-   similar to that of parent 1

#### 40. How many hours are in each shift for the second parent?

-   `maxshiftlength_parent2`
-   similar to that of parent 1

#### 41. Up to how many days per week does the second parent work?

-   `maxworkweek_parent2`
-   similar to that of parent 1

#### Employment of second parent

-   `parent_max_work`
-   unclear what this is, repetitive

#### 42. foster child status

-   `child[x]_foster_status`
-   use the foster child status; for empty entries set us -9
-   RELSHIPP = 35

#### 43.immigration status fo child

-   `child[x]_immigration_status`
-   use the immigration status variable `CIT`
-   1 = born in the U.S; 2 = born in puerto rico; 3 = born abroad of
    American parents; 4 = us citizen by naturalization; 5 = not a U.S.
    citizen

#### 44. Does any adult in the household without a Social Security Number have an ITIN instead?

-   `itin`
-   This variable is 1 or 0. We’ll also have to figure this out as part
    of the immigration status imputation process.
-   Who qualifies as no SSN? How do we infer that?

#### 45 The number of weeks the child-bearing parent takes off for recovery from childbirth and bonding

-   `mother_timeoff_for_newborn` and `other_parent_timeoff_for_newborn`
-   <https://www.newamerica.org/better-life-lab/reports/paid-family-leave-how-much-time-enough/gender-equality/#>:\~:text=And%2071%20percent%20say%20it’s,or%20adoption%20of%20a%20child.
-   11 week median for mothers; 1 week median for fathers

#### 46. NJ Middle Class Tax Rebate

-   `state_mctr`
-   always equals 1

#### 47. Family Leave Insurance (FLI) for bonding with newborns

-   `fli`

#### 48. Temporary Disability Insurance (TDI) to recover from childbirth

-   `tdi`

#### 49. baseline and compare flag

-   `baseline` and `compare_flag`
-   both are set to 0

#### 50. individual out of pocket healthcare cost

-   question: isn’t that previously covered by a household variable?
