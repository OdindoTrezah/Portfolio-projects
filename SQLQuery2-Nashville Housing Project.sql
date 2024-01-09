--Cleaning data in SQL Queries
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize date format
SELECT saledate, CONVERT(date, saledate) AS Newdate
FROM PortfolioProject.dbo.NashvilleHousing 

UPDATE NashvilleHousing
SET saledate = CONVERT(date, saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateconverted Date;

UPDATE NashvilleHousing
SET SaleDateconverted = CONVERT(date, saledate)


--Populate Property Address data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID
--parcelid and propertyaddress are similar

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.parcelid = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.parcelid = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.parcelid = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--Breaking out address into individual columns (address, city, state)

select propertyaddress
from portfolioproject.dbo.nashvillehousing
--where propertyaddress is null
--order by parcelid
SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX (',', propertyaddress) -1) as address
--SUBSTRING(propertyaddress, 1, CHARINDEX (',', propertyaddress) -1)) as address
from portfolioproject.dbo.nashvillehousing

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX (',', propertyaddress) -1) as address
, SUBSTRING(propertyaddress, CHARINDEX (',', propertyaddress) +1, LEN(propertyaddress)) as address
from portfolioproject.dbo.nashvillehousing

ALTER TABLE NashvilleHousing
ADD propertysplitaddress Nvarchar (255);

UPDATE NashvilleHousing
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX (',', propertyaddress) -1)

ALTER TABLE NashvilleHousing
ADD propertysplitcity Nvarchar (255);

UPDATE NashvilleHousing
SET propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX (',', propertyaddress) +1, LEN(propertyaddress))

select *
from PortfolioProject.dbo.NashvilleHousing



select owneraddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(owneraddress, ',', '.'), 3),
 PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
 PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD Ownersplitaddress Nvarchar (255);

UPDATE NashvilleHousing
SET ownersplitaddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD Ownersplitcity Nvarchar (255);

UPDATE NashvilleHousing
SET ownersplitcity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD Ownersplitstate Nvarchar (255);

UPDATE NashvilleHousing
SET ownersplitstate = PARSENAME(REPLACE(owneraddress, ',', '.'), 1)


--Change Y and N to Yes and No in ‘sold as vacant’ field
select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject.dbo.NashvilleHousing
group by soldasvacant
order by 2

select soldasvacant
, CASE when soldasvacant = 'Y' Then 'Yes'
      when soldasvacant = 'N' Then 'No'
	  ELSE soldasvacant
	  END
From portfolioproject.dbo.nashvillehousing

update NashvilleHousing
set soldasvacant = CASE when soldasvacant = 'Y' Then 'Yes'
      when soldasvacant = 'N' Then 'No'
	  ELSE soldasvacant
	  end


--Remove duplicates
WITH RoWnumCTE AS(
select *,
ROW_NUMBER() OVER (
PARTITION BY parcelid,
             propertyaddress,
			 saledate,
			 saleprice,
			 legalreference
			 ORDER BY
			   Uniqueid
			   ) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by parcelid
)

DELETE
from RoWnumCTE
where row_num > 1
--order by PropertyAddress

WITH RoWnumCTE AS(
select *,
ROW_NUMBER() OVER (
PARTITION BY parcelid,
             propertyaddress,
			 saledate,
			 saleprice,
			 legalreference
			 ORDER BY
			   Uniqueid
			   ) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by parcelid
)

SELECT *
from RoWnumCTE
where row_num > 1
order by PropertyAddress


--Delete unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerADDRESS, Taxdistrict, propertyaddress, saledate

select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN saledate