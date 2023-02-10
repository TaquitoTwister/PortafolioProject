-- CLEANING DATA	

SELECT * 
FROM NashvilleHousing;


-- Standarize Date Format

SELECT SaleDate, CAST(SaleDate AS DATE) AS date
FROM NashvilleHousing;

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing 
SET SaleDateConverted = CAST(SaleDate AS DATE)

SELECT SaleDateConverted, CAST(SaleDate AS DATE) AS date
FROM NashvilleHousing;


-- Populate Property Adress

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress) AS Populate
FROM NashvilleHousing AS n1
JOIN NashvilleHousing AS n2
	ON n1.[UniqueID ] != n2.[UniqueID ]
	AND n1.ParcelID = n2.ParcelID
WHERE n1.PropertyAddress IS NULL;

UPDATE n1
SET n1.PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousing AS n1
JOIN NashvilleHousing AS n2
	ON n1.[UniqueID ] != n2.[UniqueID ]
	AND n1.ParcelID = n2.ParcelID
WHERE n1.PropertyAddress IS NULL;


-- Separating Adress into Individual Columns (Adress, City, State)

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Adress, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255),
PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1), 
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress));

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing;

-----------------------------------------------------------------
-- With PARSENAME

SELECT OwnerAddress
FROM NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing;


-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END AS SoldAsVacantConverted
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


-- Remove Duplicates

WITH t1 as (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID, 
								PropertyAddress, 
								SalePrice, 
								SaleDate, 
								LegalReference 
								ORDER BY [UniqueID ]) as NumberDup
FROM NashvilleHousing
)

DELETE
FROM t1
WHERE NumberDup > 1;



-- Remove Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

SELECT *
FROM NashvilleHousing;