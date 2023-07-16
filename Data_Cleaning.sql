/*

Cleaning Data in SQL

*/

SELECT *
FROM TestBench.dbo.HousingData

----------------------------------------------------------------------------------------------

--Standardize Date format


ALTER TABLE HousingData
ADD SaleDateConverted Date 

UPDATE HousingData
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM TestBench.dbo.HousingData



----------------------------------------------------------------------------------------------

--Populate Property Address Data
--Similar Parcel ID should be same Address

SELECT *
FROM TestBench.dbo.HousingData
WHERE PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM TestBench.dbo.HousingData a
JOIN TestBench.dbo.HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM TestBench.dbo.HousingData a
JOIN TestBench.dbo.HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



----------------------------------------------------------------------------------------------

--Break Address into Components
--delimited by comma


SELECT *
FROM TestBench.dbo.HousingData

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM TestBench.dbo.HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress nvarchar(255)

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE HousingData
ADD PropertySplitCity nvarchar(255)

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


-- same for owner address


SELECT OwnerAddress
FROM TestBench.dbo.HousingData


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM TestBench.dbo.HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress nvarchar(255)

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE HousingData
ADD OwnerSplitCity nvarchar(255)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE HousingData
ADD OwnerSplitState nvarchar(255)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



SELECT *
FROM TestBench.dbo.HousingData


----------------------------------------------------------------------------------------------

--Standardize 'sold as vacant' column

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM TestBench.dbo.HousingData
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM TestBench.dbo.HousingData


UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END



----------------------------------------------------------------------------------------------

--Remove Duplicates




WITH RowNumCTE AS(
SELECT *
, ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
			   PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   ORDER BY UniqueID
			   ) row_num

FROM TestBench.dbo.HousingData
)
DELETE
FROM RowNumCTE
WHERE row_num >1



WITH RowNumCTE AS(
SELECT *
, ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
			   PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   ORDER BY UniqueID
			   ) row_num

FROM TestBench.dbo.HousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num >1


----------------------------------------------------------------------------------------------

--Delete Unused Columns


SELECT *
FROM TestBench.dbo.HousingData

ALTER TABLE HousingData
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress
