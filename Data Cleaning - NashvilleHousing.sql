-- DATA CLEANING WITH SQL USING NASHVILLE HOUSING DATA SET

SELECT * FROM PortfolioProject..NashvilleHousing

-- STANDARDIZE DATE FORMAT
SELECT SaleDate 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SalesDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing 
 SET SalesDateConverted = Convert(Date, SaleDate)

 SELECT SalesDateConverted FROM PortfolioProject..NashvilleHousing

 --Populate Property Address Date 
 SELECT * 
 FROM PortfolioProject..NashvilleHousing
 --WHERE PropertyAddress IS NULL
 ORDER BY ParcelID

 select a.ParcelID, a.PropertyAddress,  b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
 join PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
 join PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into Individual columns (Address, City & State)
Select PropertyAddress 
From PortfolioProject..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress varchar(255);

UPDATE PortfolioProject..NashvilleHousing 
 SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

 ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity varchar(255);

UPDATE PortfolioProject..NashvilleHousing 
 SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

 ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState varchar(255);

UPDATE PortfolioProject..NashvilleHousing 
 SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

-- Change Y to Yes and N to No in SoldAsVacant column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
   CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant 
		END
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant 
		END

--Remove Duplicates
WITH RowNumCTE as (
Select * ,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   LegalReference
				   ORDER BY 
				      UniqueID
					  ) row_num
From PortfolioProject..NashvilleHousing
)
Select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

-- Delete Unused Columns 
Select * From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 