--  This sample data cleaning is done on Nashville Housing data by following Alex the Analyst Youtube video
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--1. Standardize date format
SELECT SaleDate,CONVERT(DATE,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)

SELECT SaleDate
from PortfolioProject.dbo.NashvilleHousing
--Not working so altering table and adding new column and storing the converted date in the new one see in further queries

ALTER TABLE NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2=CONVERT(Date,SaleDate)

SELECT SaleDate2
from PortfolioProject.dbo.NashvilleHousing

--2. Populate property address data
SELECT *
from PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID 
--Where PropertyAddress is NULL

SELECT Temp1.ParcelID,Temp1.PropertyAddress,Temp2.ParcelID,Temp2.PropertyAddress, ISNULL(Temp1.PropertyAddress,Temp2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing Temp1
JOIN PortfolioProject.dbo.NashvilleHousing Temp2
	on Temp1.ParcelID=Temp2.ParcelID
	AND Temp1.[UniqueID ] <>Temp2.[UniqueID ]
WHERE Temp1.PropertyAddress is Null

UPDATE Temp1
SET PropertyAddress=ISNULL(Temp1.PropertyAddress,Temp2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing Temp1
JOIN PortfolioProject.dbo.NashvilleHousing Temp2
	on Temp1.ParcelID=Temp2.ParcelID
	AND Temp1.[UniqueID ] <>Temp2.[UniqueID ]
Where Temp1.PropertyAddress is null

--3. Breaking out Address Into Individual Columns(Address, City, State)
SELECT PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
fROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


Update NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);


Update NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--4. Change Y & N with Yes And No in Sold and Vacant Field
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
CASE When SoldAsVacant='Y' THEN 'Yes'
	When SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET 
SoldAsVacant = CASE When SoldAsVacant='Y' THEN 'Yes'
	When SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing


--5. Rempove Duplicates
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				  ) Row_Num
FROM PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
--DELETE 
SELECT *
From RowNumCTE

--Order by PropertyAddress

--6. Delete unused columns
Select *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
