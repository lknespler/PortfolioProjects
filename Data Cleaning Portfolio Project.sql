/*
Cleaning Data in SQL queries
*/

SELECT * FROM NashvilleHousing;

-- --------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDate FROM NashvilleHousing;
SELECT SaleDate, Convert(SaleDate, Date) FROM NashvilleHousing;
Update NashvilleHousing
SET SaleDate = Convert(SaleDate, Date);

-- or

ALTER Table NashvilleHousing
ADD SaleDateConverted Date;
Update NashvilleHousing
SET SaleDateConverted = Convert(SaleDate, Date)

SELECT SaleDateConverted, Convert(SaleDate, Date) FROM NashvilleHousing;

-- --------------------------------------------------------------------------------------------------------------

-- Populate Property Adress data

SELECT *
FROM NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE
    NashvilleHousing a JOIN NashvilleHousing b 
		ON (a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID)
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress is null;

-- --------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1, LOCATE(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+ 1, LENGTH(PropertyAddress)) as City
FROM NashvilleHousing

ALTER Table NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, LOCATE(',', PropertyAddress) - 1)

ALTER Table NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+ 1, LENGTH(PropertyAddress))

SELECT OwnerAddress
FROM NashvilleHousing

SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address, 
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City, 
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM NashvilleHousing

ALTER Table NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1)

ALTER Table NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)

ALTER Table NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1)

-- --------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field 

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		   WHEN SoldAsVacant = 'N' THEN 'No' 
		   ELSE SoldAsVacant 
			 END 
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		   WHEN SoldAsVacant = 'N' THEN 'No' 
		   ELSE SoldAsVacant 
			 END; 

-- --------------------------------------------------------------------------------------------------------------

-- Remove Duplicates without using UniqueID

SELECT 
	ParcelID 
FROM (
	SELECT 
		ParcelID,
		ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, 
		SaleDate, LegalReference ORDER BY UNIQUEID) AS row_num
		FROM NashvilleHousing
) t
WHERE 
	row_num > 1;

-- First way to delete duplicates with Row_Number()

DELETE FROM NashvilleHousing 
WHERE 
	ParcelID IN (
	SELECT 
		ParcelID 
	FROM (
		SELECT ParcelID,
		ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, 
		SaleDate, LegalReference ORDER BY UNIQUEID) AS row_num
		FROM NashvilleHousing
	) t
    WHERE row_num > 1
);

-- Second way to delete duplicates with Row_Number()

WITH CteToDelete AS 
(
   SELECT ParcelID,
          ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, 
		SaleDate, LegalReference ORDER BY UNIQUEID) AS row_num
   FROM NashvilleHousing
)   
DELETE FROM NashvilleHousing USING NashvilleHousing JOIN CteToDelete 
	ON NashvilleHousing.ParcelID = CteToDelete.ParcelID
WHERE CteToDelete.row_num > 1; 

-- --------------------------------------------------------------------------------------------------------------

-- Delete unused Columns 

ALTER Table NashvilleHousing 
DROP COLUMN OwnerAddress, 
DROP TaxDistrict, 
DROP PropertyAddress,
DROP SaleDate 

-- --------------------------------------------------------------------------------------------------------------

-- Importing data using Bulk INSERT
insert into NashvilleHousing(UniqueID, ParcelID, LandUse, SalePrice, LegalReference, SoldAsVacant, OwnerName) 
values 
('insert1', '123 45 6 789.00', 'DUPLEX', '360000', '20130412-0036474', 'No', 'BAKER, JAY K. & SUSAN E.'),
('insert2', '132 45 6 789.00','DUPLEX', '600000', '20130412-0036474', 'Yes', 'Lauren K.'),
('insert3', '321 45 6 789.00','DUPLEX', '560000', '20130412-0036474', 'No', 'John doe');

SELECT *
FROM NashvilleHousing
WHERE (UniqueID LIKE '%insert%') 

DELETE
FROM NashvilleHousing
WHERE (UniqueID LIKE '%insert%');

