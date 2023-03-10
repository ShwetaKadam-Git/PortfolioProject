/** This sample data cleaning is done on Nashville Housing data by following Alex the Analyst Youtube video
The data file I used is also attached in this project section. You can import it via SQL Import Export Wizard and try below queries if you like.
Functions/Key concepts used in this data cleaning -
	SUBSTRING(string, start, length) - It extracts the string from your input string based on the start and end index
	CHARINDEX(substring, string, start) - searches for a substring in a string, and returns the position 
	LEN(string) - It returns the length of a string
	ISNULL(expression, replacement) - This function is used to replace NULL with a specified value. Input expression of any type is checked for null value and if it is null then it'll be replaced with Replacement string/value given in the function
	CONVERT(data_type(length), expression, style(OPTIONAL)) - This function converts a value (of any type) into a specified datatype.
	PARSENAME('NameOfStringToParse',PartIndex) - This function returns the specific part of given string (to split delimited data,to return a value from a specified position in a "Dot" delimited string)
	CTE - the common table expression (CTE) is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 
	The CTEs can be a useful when you need to generate temporary result sets that can be accessed in a SELECT, INSERT, UPDATE, DELETE, or MERGE statement.
	
**/
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--1. Standardize date format
SELECT SaleDate,CONVERT(DATE,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)

SELECT SaleDate
from PortfolioProject.dbo.NashvilleHousing
--The update statement did not work somehow so altering table and adding new column and storing the converted date in the new column SaleDate2 see in further queries

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

--It is always better to select the data which you want to update in order to be sure that you are not updating wrong data
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
--3.1 Queries used to split the Property address and store it as Address, City in two separate columns
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

--3.2 Queries used to split the Owner address and store it in three separate columns i.e., Address, City, State 
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
