create database portfolioprojecthouse;
select count(*) from nashvillehouse_file2;
select * from nashvillehouse_file2;

-- standardize date format:

describe nashvillehouse_file2 ;
ALTER TABLE nashvillehouse_file2
ADD COLUMN SaleDate_new DATE;
UPDATE nashvillehouse_file2
SET SaleDate_new = STR_TO_DATE(SaleDate, '%M %d, %Y');

-- Populate Property Address data:
select * from nashvillehouse_file2
-- where PropertyAddress is null
order by ParcelID;
-- yha bde saare same honge


select a.ParcelID, a.PropertyAddress, b.ParcelID,
b.PropertyAddress , ifnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehouse_file2 a
JOIN nashvillehouse_file2 b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
-- uniqueid is row no in this data
where a.PropertyAddress is null;

Update nashvillehouse_file2 a
JOIN nashvillehouse_file2 b
 on a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress is null; 

-- breaking out address into individual columns (adress, city, state):

select PropertyAddress from nashvillehouse_file2;
 
 SELECT SUBSTRING(PropertyAddress ,1, LOCATE(',', PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress ,LOCATE(',', PropertyAddress)+1 , CHAR_LENGTH(PropertyAddress)) as Address
 From nashvillehouse_file2;
 
 ALTER TABLE nashvillehouse_file2
 add PropertySplitAddress Nvarchar(255);
 update nashvillehouse_file2
 SET PropertySplitAddress = SUBSTRING(PropertyAddress ,1, LOCATE(',', PropertyAddress)-1);
 
 ALTER TABLE nashvillehouse_file2
 add PropertySplitCity Nvarchar(255);
 Update nashvillehouse_file2
 SET PropertySplitCity = SUBSTRING(PropertyAddress ,LOCATE(',', PropertyAddress)+1 , CHAR_LENGTH(PropertyAddress));

select * from nashvillehouse_file2;

Select OwnerAddress From nashvillehouse_file2;
-- another way
select SUBSTRING_INDEX(OwnerAddress, ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
SUBSTRING_INDEX(OwnerAddress, ',', -1)
from nashvillehouse_file2;

ALTER TABLE nashvillehouse_file2
 add OwnerSplitAddress Nvarchar(255);
 Update nashvillehouse_file2
 SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);
 
 ALTER TABLE nashvillehouse_file2
 add OwnerSplitCity Nvarchar(255);
 Update nashvillehouse_file2
 SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);
 
 ALTER TABLE nashvillehouse_file2
 add OwnerSplitState Nvarchar(255);
 Update nashvillehouse_file2
 SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

select * from nashvillehouse_file2;

-- change Y and N to Yes and No in 'sold as Vacant' field:

Select Distinct(SoldAsVacant), count(SoldAsVacant)  from nashvillehouse_file2
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
from nashvillehouse_file2;


update nashvillehouse_file2
SET SoldAsVacant=
case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END;
     

-- Remove Duplicates :

WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate_new,
LegalReference ORDER BY UniqueID) row_num 
 from nashvillehouse_file2
-- order by ParcelID;
)
SELECT *
from RowNumCTE
WHERE row_num > 1;
-- by PropertyAddress;
-- then use delete from RowNumCTE WHERE row_num > 1
     
-- delete unused columns:

ALTER TABLE nashvillehouse_file2
DROP COLUMN OwnerAddress ,
DROP COLUMN TaxDistrict , 
DROP COLUMN PropertyAddress;

ALTER TABLE nashvillehouse_file2
DROP COLUMN SaleDate;