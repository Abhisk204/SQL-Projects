/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [index]
      ,[State_Name]
      ,[District_Name]
      ,[Season]
      ,[Crop]
      ,[Area]
      ,[Production]
      ,[Crop_Year]
  FROM [PracticeDB1].[dbo].[IndiaCropProductionStatewise]
  order by [index] desc

--Check the Year range for which data is present
select distinct Season from dbo.IndiaCropProductionStatewise --order by  Crop_Year desc

--Check for any null values.(3730 rows are having NULL in Production Column.)
select * from dbo.IndiaCropProductionStatewise where [index] is null
or State_Name is null
or District_Name is null
or Season is null
Or crop is null
or area is null
or production is null
or Crop_Year is null


--On checking it was found that Chandigarh data was ambiguous because the state name was unclear and it was written Chandigarh.

Select * from dbo.IndiaCropProductionStatewise where State_UT_Name IN ('Chandigarh')

--So let's create a inline table valued function to give the rows where State_UT_Name is not Chandigarh

create function fn_dbo_IndiaCropProductionStatewise()
returns Table
as
Return (Select [index],State_UT_Name,District_Name,Season,Crop,Area,Production,Crop_Year from dbo.IndiaCropProductionStatewise where
		State_UT_Name <> 'Chandigarh' and Crop_Year <> 2015)

/*On checking the function output,it was found that the ambiguous data of Chandigarh was removed.*/

select * from fn_dbo_IndiaCropProductionStatewise() where State_UT_Name = 'Chandigarh' or UPPER(District_Name) = 'CHANDIGARH'


--------State with largest production of Crop in various Seasons.
--Season -> Whole Year

Select State_UT_Name,SUM(Production) as [Production_Total in metric tons]
from dbo.fn_dbo_IndiaCropProductionStatewise()
where Season = 'Whole Year'
group by State_UT_Name
Order by SUM(Production) desc

--Season -> Kharif

Select State_UT_Name,SUM(Production) as [Production_Total in metric tons]
from dbo.fn_dbo_IndiaCropProductionStatewise()
where Season = 'Kharif'
group by State_UT_Name
Order by SUM(Production) desc

--Season -> Rabi

Select State_UT_Name,SUM(Production) as [Production_Total in metric tons]
from dbo.fn_dbo_IndiaCropProductionStatewise()
where Season = 'Rabi'
group by State_UT_Name
Order by SUM(Production) desc

--Season -> Summer

Select State_UT_Name,SUM(Production) as [Production_Total in metric tons]
from dbo.fn_dbo_IndiaCropProductionStatewise()
where Season = 'Summer'
group by State_UT_Name
Order by SUM(Production) desc

--Season -> Autumn

Select State_UT_Name,SUM(Production) as [Production_Total in metric tons]
from dbo.fn_dbo_IndiaCropProductionStatewise()
where Season = 'Autumn'
group by State_UT_Name
Order by SUM(Production) desc

--Season -> Winter

Select State_UT_Name,SUM(Production) as [Production_Total in metric tons]
from dbo.fn_dbo_IndiaCropProductionStatewise()
where Season = 'Winter'
group by State_UT_Name
Order by SUM(Production) desc


--Year having highest Production of all the crops.(On analyzing it was found that 2005 has the highest production of crops from 1997-2014)

with cte1 as(
Select Crop_Year,State_UT_Name,
SUM(Production) OVER (PARTITION BY Crop_Year,State_UT_Name) as Total_Production
from dbo.fn_dbo_IndiaCropProductionStatewise()
)
Select Crop_Year,MAX(Total_Production) as [Max Total Production]
from cte1 
group by Crop_Year
order by MAX(Total_Production) desc

/*Top State with highest production of crops each year from 1997-2014.*/

with cte1 as(
Select Crop_Year,State_UT_Name,
SUM(Production) OVER (PARTITION BY Crop_Year,State_UT_Name) as Total_Production
from dbo.fn_dbo_IndiaCropProductionStatewise()
)
select Crop_Year,State_UT_Name,Total_Production
from(
		select *,ROW_NUMBER() over (PARTITION BY Crop_Year /*,State_UT_Name*/ ORDER BY Total_Production DESC) as Rank_CropYear_TotalProd--Crop_Year,MAX(Total_Production) [Maximum Total Production]
		from cte1
	) as Derived_Table
where Rank_CropYear_TotalProd = 1

----Since the major staple food of India is rice or wheat.Let's see which state has produced most wheat and rice in the year 1997-2014.

select * from dbo.fn_dbo_IndiaCropProductionStatewise() where UPPER(Crop) = 'RICE'
or UPPER(Crop) = 'WHEAT'


--Largest Producer of Rice by Year and State

with cte2 as(
	select Crop_Year,State_UT_Name, ROW_NUMBER() OVER (PARTITION BY Crop_Year ORDER BY [Total Production] DESC) as Rank_of_Rice
	from(
		Select Crop_Year,State_UT_Name , SUM(Production) [Total Production]
		from dbo.fn_dbo_IndiaCropProductionStatewise()
		where UPPER(Crop) = 'RICE'
		group by Crop_Year,State_UT_Name
		) as Derived_Table
)
select Crop_Year,State_UT_Name as [Largest Rice Producer State] from cte2 where Rank_of_Rice = 1 /*It was found that WestBengal was the largest producer of Rice from 1997
 to 2013 , Andhra Pradesh was in 2014*/

 --Largest Producer of Rice by Year and State
 with cte2 as(
	select Crop_Year,State_UT_Name, ROW_NUMBER() OVER (PARTITION BY Crop_Year ORDER BY [Total Production] DESC) as Rank_of_Wheat
	from(
		Select Crop_Year,State_UT_Name , SUM(Production) [Total Production]
		from dbo.fn_dbo_IndiaCropProductionStatewise()
		where UPPER(Crop) = 'WHEAT'
		group by Crop_Year,State_UT_Name
		) as Derived_Table
)
select Crop_Year,State_UT_Name as [Largest Wheat Producer State] from cte2 where Rank_of_Wheat = 1 /*It was found that Uttar Pradesh was the largest producer of Rice from 1997
 to 2014 */