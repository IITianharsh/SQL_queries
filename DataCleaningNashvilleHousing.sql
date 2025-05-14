use Data_Cleaning

select * from Data_Cleaning.dbo.NashvilleHousing

--standardize date format


select SaleDateConverted , convert(date,SaleDate)
from Data_Cleaning.dbo.NashvilleHousing

update NashvilleHousing  ---not working
set SaleDate= convert(date,SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted= convert(date,SaleDate)

--Populate property address data

select PropertyAddress
from Data_Cleaning.dbo.NashvilleHousing
where PropertyAddress is null

select *
from Data_Cleaning.dbo.NashvilleHousing
where PropertyAddress is null

select *
from Data_Cleaning.dbo.NashvilleHousing
--   as parcelId is same for property address
order by ParcelID

--self join
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Data_Cleaning.dbo.NashvilleHousing a
Join Data_Cleaning.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress) --if a.prop is null populate b.prop
from Data_Cleaning.dbo.NashvilleHousing a
Join Data_Cleaning.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.propertyAddress,b.PropertyAddress)
from Data_Cleaning.dbo.NashvilleHousing a
Join Data_Cleaning.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into indivisual column

select PropertyAddress
from Data_Cleaning.dbo.NashvilleHousing
--   as parcelId is same for property address
--order by ParcelID

select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address ----separates from delimiter before delimiter
, SUBSTRING(propertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(propertyAddress)) as Address -- after delimiter 
from Data_Cleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress= SUBSTRING(propertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity= SUBSTRING(propertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(propertyAddress))


select*
from Data_Cleaning.dbo.NashvilleHousing


--same for owner address

select OwnerAddress
from Data_Cleaning.dbo.NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1) ---parsename does things backwords
from Data_Cleaning.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress= PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
add OwnertySplitAddress nvarchar(255);

update NashvilleHousing
set OwnertySplitAddress=PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


select *
from Data_Cleaning.dbo.NashvilleHousing


---change Y and N to Yes and No in Sold as vacant column

select distinct(soldasvacant), COUNT(soldasvacant)
from Data_Cleaning.dbo.NashvilleHousing
group by soldasvacant
order by 2

select SoldAsVacant
, case when SoldAsVacant= 'Y' then 'Yes'
	   when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
		end
from Data_Cleaning.dbo.NashvilleHousing

update NashvilleHousing
set Soldasvacant = case when SoldAsVacant= 'Y' then 'Yes'
	   when SoldAsVacant='N' then 'No'
	   else SoldAsVacant
		end
from Data_Cleaning.dbo.NashvilleHousing

select distinct(soldasvacant), COUNT(soldasvacant)
from Data_Cleaning.dbo.NashvilleHousing
group by soldasvacant
order by 2;


--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() over(
	partition by parcelId,
				 propertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

from Data_Cleaning.dbo.NashvilleHousing
)
select * 
From RowNumCTE
where row_num>1
order by PropertyAddress ------ gives Duplicate 



WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() over(
	partition by parcelId,
				 propertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

from Data_Cleaning.dbo.NashvilleHousing
)
Delete  
From RowNumCTE
where row_num>1 ---deletes duplicate


---deletes unused columns 

select *
from Data_Cleaning.dbo.NashvilleHousing

Alter table Data_Cleaning.dbo.NashvilleHousing
drop column owneraddress, TaxDistrict, PropertyAddress

Alter table Data_Cleaning.dbo.NashvilleHousing
drop column saledate



-----The End---