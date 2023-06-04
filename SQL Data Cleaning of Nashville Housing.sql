--Cleaning the data
select * from [dbo].[NashvilleHousing]

--Standaradize the Date Format
select SaleDateConverted,cast(SaleDate as Date)
from NashvilleHousing

Update dbo.NashvilleHousing
set SaleDate = Cast(SaleDate as Date) -- it doesnot work.So lets use alter

Alter table dbo.NashvilleHousing
add SaleDateConverted Date

Update dbo.NashvilleHousing
set SaleDateConverted = Cast(SaleDate as Date)



--Populate Property Address Data
select * from dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID


select a.ParcelId,a.PropertyAddress
,b.ParcelID,b.PropertyAddress
,isnull(a.propertyAddress,b.PropertyAddress)
from NashVilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyAddress,b.PropertyAddress)
from NashVilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Breaking out Address Into Individual Columns(Address,City,State)

select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by parcelID

Select Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from NashvilleHousing


Alter table NashvilleHOusing
add PropertySplitAddress Nvarchar(255)

Alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Update NashvilleHousing
set PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--Now owneraddress
select * from NashvilleHousing
select PARSENAME(REPLACE(OwnerAddress,',','.'),1) from NashvilleHousing

--PARSENAME() always works with periods(.).

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and NO in Sold as Vacant Field.
select SoldasVacant ,Count(SoldasVacant)
from NashvilleHousing
group by SoldasVacant

select SoldasVacant,Case
when SoldasVacant = 'Y' then 'Yes'
when SoldasVacant = 'N' then 'No'
else SoldasVacant
end
from NashvilleHousing
where SoldasVacant IN ('Y','N')

update NashvilleHousing
set SoldasVacant = Case
when SoldasVacant = 'Y' then 'Yes'
when SoldasVacant = 'N' then 'No'
else SoldasVacant
end


--Delete unused columns
Alter table NashvilleHousing
drop column SaleDate
--OwnerAddress,TaxDistrict,PropertyAddress

select * from NashvilleHousing




