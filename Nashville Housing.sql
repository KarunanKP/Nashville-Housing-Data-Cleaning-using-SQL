create database	Nashville_Housing;
select * from nashville_housing_data;

-- ----------------------------------------------------------------------------------------------------------------
-- Formating SaleDate Column
select SaleDate, date(SaleDate) from nashville_housing_data;

update nashville_housing_data
set SaleDate = date(SaleDate); -- Can't able to update SaleDate Column   
                             
-- So creating a new table and Populating it with formated SaleDate column  
alter table nashville_housing_data
add SaleDateConverted date;

update nashville_housing_data
set SaleDateConverted = date(SaleDate);

-- ----------------------------------------------------------------------------------------------------------------
-- Populating Null values in PropertyAddress Column

select * from nashville_housing_data
where PropertyAddress is null; -- we can see some null Values in the PropertyAddress Column 

select * from nashville_housing_data
order by ParcelID; -- we can see that a ParcelID has a respective PropertyAddress so we can populate the null values with it

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, coalesce(a.PropertyAddress, b.PropertyAddress)
from nashville_housing_data a
join nashville_housing_data b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;
-- using coalesce function to select first not null values from the rows
 
update nashville_housing_data a join nashville_housing_data b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
set a.PropertyAddress = coalesce(a.PropertyAddress, b.PropertyAddress)
where a.PropertyAddress is null;

-- ----------------------------------------------------------------------------------------------------------------
-- Seperating City from PropertyAddress
select substring_index(PropertyAddress, ',', 1) as SplitPropertyAddress, -- Spliting City from Address
trim(substring_index(PropertyAddress, ',', -1)) as SplitPropertyCity -- Using Trim to eliminate extra Spaces
from nashville_housing_data;

alter table nashville_housing_data
add SplitPropertyAddress varchar(255);

update nashville_housing_data
set SplitPropertyAddress = substring_index(PropertyAddress, ',', 1);

alter table nashville_housing_data
add SplitPropertyCity varchar(255);

update nashville_housing_data
set SplitPropertyCity = trim(substring_index(PropertyAddress, ',', -1));

-- ----------------------------------------------------------------------------------------------------------------
-- Seperating Address, City, State from OwnerAddress
select trim(substring_index(OwnerAddress,',', 1)) as SplitOwnerAddress,
trim(substring_index(substring_index(OwnerAddress,',', 2),',',-1)) as SplitOwnerCity,
trim(substring_index(OwnerAddress,',', -1)) as SplitOwnerState
from nashville_housing_data;

alter table nashville_housing_data
add SplitOwnerAddress varchar(255);

update nashville_housing_data
set SplitOwnerAddress = trim(substring_index(OwnerAddress,',', 1));


alter table nashville_housing_data
add SplitOwnerCity varchar(255);

update nashville_housing_data
set SplitOwnerCity = trim(substring_index(substring_index(OwnerAddress,',', 2),',',-1));


alter table nashville_housing_data
add SplitOwnerState varchar(255);

update nashville_housing_data
set SplitOwnerState = trim(substring_index(OwnerAddress,',', -1));

-- ----------------------------------------------------------------------------------------------------------------
-- Changing Y and N to Yes and No in "SoldAsVacant" field

select SoldAsVacant, count(SoldAsVacant) from nashville_housing_data group by SoldAsVacant;

select SoldAsVacant, 
case when SoldAsVacant= 'y' then 'Yes'
     when SoldAsVacant= 'n' then 'No'
     else SoldAsVacant
     end
from nashville_housing_data;

update nashville_housing_data
set SoldAsVacant = case when SoldAsVacant= 'y' then 'Yes'
						when SoldAsVacant= 'n' then 'No'
						else SoldAsVacant
				   end;

-- ----------------------------------------------------------------------------------------------------------------
-- Removing Duplicate Values
with RowNumCte as (
select *, row_number() over(partition by  ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
						 order by UniqueID) rownum
from nashville_housing_data)
select * from rownumcte where rownum > 1;

with RowNumCte as (
select *, row_number() over(partition by  ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
						 order by UniqueID) rownum
from nashville_view)
delete nv from nashville_housing_data nv 
join rownumcte r on nv.UniqueID = r.UniqueID
where rownum > 1; -- Deleted Duplicate values

-- ----------------------------------------------------------------------------------------------------------------
-- Reordering Columns
alter table nashville_housing_data
modify column SplitPropertyAddress varchar(255) after PropertyAddress;

alter table nashville_housing_data
modify column SaleDateConverted date after SaleDate,
modify column SplitPropertyCity varchar(255) after SplitPropertyAddress,
modify column SplitOwnerAddress varchar(255) after OwnerAddress,
modify column SplitOwnerCity varchar(255) after SplitOwnerAddress,
modify column SplitOwnerState varchar(255) after SplitOwnerCity;

-- ----------------------------------------------------------------------------------------------------------------
-- Droping Columns
alter table nashville_housing_data
drop column PropertyAddress,
drop column SaleDate,
drop column OwnerAddress;

-- ----------------------------------------------------------------------------------------------------------------
-- renaming Columns
alter table nashville_housing_data
change SplitPropertyAddress PropertyAddress varchar(255),
change SplitPropertyCity PropertyCity varchar(255),
change SaleDateConverted SaleDate date,
change SplitOwnerAddress OwnerAddress varchar(255),
change SplitOwnerCity OwnerCity varchar(255),
change SplitOwnerState OwnerState varchar(255); 

-- ----------------------------------------------------------------------------------------------------------------
-- Creating a View 
create view nashville_view as 
select * from nashville_housing_data;

select * from nashville_view;

