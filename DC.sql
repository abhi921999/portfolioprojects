SELECT *
FROM [Project_22].[dbo].[Nashville Housing Data for Data Cleaning]

SELECT *
FROM [Project_22].[dbo].[Nashville Housing Data for Data Cleaning]
--where PropertyAddress is Null;
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL( a.PropertyAddress,b.PropertyAddress)
FROM [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] a
join [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is Null;

update a
set PropertyAddress=ISNULL( a.PropertyAddress,b.PropertyAddress)
FROM [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] a
join [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is Null;

 -- breaking address into individual aspects
 SELECT PropertyAddress
 FROM [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 

 Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
 from [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 

 Alter table [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Add PropertySplitAddress NVarchar(255)

 Update [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

  Alter table [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Add PropertySplitCity NVarchar(255)

  Update [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

 Select * from [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] ;

  Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
  PARSENAME(REPLACE(OwnerAddress,',','.'),2),
  PARSENAME(REPLACE(OwnerAddress,',','.'),1)
  from [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] ;

  Alter table [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Add OwnerSplitAddress NVarchar(255)

 Update [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

  Alter table [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Add OwnerSplitCity NVarchar(255)

  Update [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

 Alter table [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Add OwnerSplitState NVarchar(255)

 Update [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] 
 Set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

  Select * from [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] ;

  --identifying duplicates
WITH ROWNUMCTE AS(
  select *, ROW_NUMBER() over (
	partition by ParcelId,PropertyAddress,Saleprice,SaleDate,LegalReference
	order by UniqueID) row_num
from [Project_22].[dbo].[Nashville Housing Data for Data Cleaning] )

--Select * from ROWNUMCTE where  row_num>1
--order by PropertyAddress;

--deleting duplicate
Delete from ROWNUMCTE where  row_num>1;

