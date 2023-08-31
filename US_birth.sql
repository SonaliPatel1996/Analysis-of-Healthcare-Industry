/*
Data contains 5496 rows about number of birth, State, State_Abbreviation, Year, Gender, Education_Level_of_Mother, 
Education_Level_Code, Average_Age_of_Mother, Average_Birth_Weight_gm.
Country= US
Year= 2016 TO 2021
Souce= Kaggle
*/

create database superstore;
use superstore;
show tables;

select * from us_birth;

-- No. of births group by state, Year, Gender,Education_Level_of_Mother, Average_Age_of_Mother

select state, Year, Gender,Education_Level_of_Mother, sum(Number_of_Births), Average_Age_of_Mother from us_birth
group by 1,2,3,4,6;


-- total_birth ratio by year

select year, sum(number_of_births) as total_birth
from us_birth
group by 1;


-- Number of births by state in year = 2021
-- using RANK function with where clause

select state, sum(Number_of_Births) as Total_birth,
		rank() over (order by sum(Number_of_Births) desc) as "Ranking-2021"
from us_birth
where year = 2021
group by state
order by sum(Number_of_Births) desc
limit 10;


-- Total_Birth group by Education level of mother and year

select Education_Level_of_Mother, sum(Number_of_Births) as Total_birth, Year from us_birth
group by Education_Level_of_Mother, Year;


-- Total Birth group by gender and year

select Year, Gender, sum(Number_of_Births) as total_birth from us_birth
group by year, gender
order by Year;


-- categorized Average_Birth_Weight_gm by Healthy (>=2700) and Low_weight (1500 to 2700)

select Year, State, sum(Number_of_Births) as Total_birth,
case
	when Average_Birth_Weight_gm between 1500 and 2700 then "Low Weight Baby"
    when Average_Birth_Weight_gm >=2700 then "Healthy Baby"
END as Baby_category
from us_birth
group by Year, State, Baby_category;


-- lowest and highest birth rate under each education_level_of_mother corresponding to each state
-- (window function with window clause)

select state, year, number_of_births,
first_value(education_level_of_mother) over w as highest_birth_state,
last_value(education_level_of_mother) over w as least_birth_state
from us_birth
window w as (partition by state order by Number_of_Births desc
range between unbounded preceding and unbounded following);


-- segregate Age_of_mother into 3 parts
-- Using NTILE FUNCTION WITH CASE

select state,year, gender, education_level_of_mother,number_of_births, average_age_of_mother,
case when x.bucket =1 then 'Young Age Mother'
	 when x.bucket =2 then 'Middle Age Mother'
	 when x.bucket =3 then 'Matured Age Mother'
END age_category
from 
(
select state,year, gender, education_level_of_mother,number_of_births, average_age_of_mother,
ntile (3) over (order by average_age_of_mother) as bucket
from us_birth
group by 1,2,3,4,5,6
) x;
