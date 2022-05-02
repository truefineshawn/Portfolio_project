USE portfolioproject;
select * from nashvillehousing;

-- standarize Date format
Select saledate, STR_TO_DATE(saledate, '%M %d, %Y')
from nashvillehousing;

Update nashvillehousing
set saledate = STR_TO_DATE(saledate, '%M %d, %Y');

-- Populate Property Address data
-- findout NULL values or '' value
select propertyaddress
from nashvillehousing
where propertyaddress is null OR propertyaddress = '';

-- Check if the null address property belongs to same parcel ID and if yes, replace null value to the same address
-- Update the address
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, IF(a.propertyaddress = '', b.propertyaddress, a.propertyaddress)
from nashvillehousing a
join nashvillehousing b
on a.parcelid = b.parcelid and a.uniqueid <> b.uniqueid
where a.propertyaddress = '';

update nashvillehousing a, nashvillehousing b
set a.propertyaddress = b.propertyaddress
where a.parcelid = b.parcelid
	AND a.propertyaddress = ''
     AND a.uniqueid <> b.uniqueid
     AND b.propertyaddress <> '';
     
-- Breaking out address into seperate columns (Address, city, State)
-- property address
Select propertyaddress, substring_index(propertyaddress, ',', 1) AS address, substring_index(propertyaddress, ',', -1) AS city
from nashvillehousing;

alter table nashvillehousing
add property_address varchar(255);
update nashvillehousing
set property_address = substring_index(propertyaddress, ',', 1);

alter table nashvillehousing
add property_city varchar(255);
update nashvillehousing
set property_city = substring_index(propertyaddress, ',', -1);

-- owner address
select owneraddress, 
		substring_index(owneraddress, ', ', 1) AS ownerstreet, 
		substring_index(substring_index(owneraddress, ', ', 2), ', ', -1) AS ownercity,
          substring_index(owneraddress, ', ', -1) AS ownerstate
from nashvillehousing;

alter table nashvillehousing
add ownerstreet varchar(255) after owneraddress,
add ownercity varchar(255) after ownerstreet,
add ownerstate varchar(255) after ownercity;

update nashvillehousing
set ownerstreet = substring_index(owneraddress, ', ', 1), 
	ownercity = substring_index(substring_index(owneraddress, ', ', 2), ', ', -1), 
	ownerstate =  substring_index(owneraddress, ', ', -1);

-- Changing N and Y to 'No' and 'Yes' in SoldAsVacant column
select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant;

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
          else soldasvacant
end AS soldasvacant
from nashvillehousing;
-- where soldasvacant = 'N' (for testing result use)

update nashvillehousing
set soldasvacant = 
		case when soldasvacant = 'Y' then 'Yes'
				when soldasvacant = 'N' then 'No'
				else soldasvacant
				end;
                    
-- Removing duplicates
-- Approach 1
With rownumCTE AS(
select *,
	row_number() over(
     partition by parcelid, 
					propertyaddress, 
					saleprice, 
					saledate, 
					legalreference
					order by uniqueid
					) AS row_num
from nashvillehousing
order by parcelid
)
select*
from rownumCTE
where row_num >1;

-- Approach 2
select parcelid, row_num
from (
select *,
	row_number() over(
     partition by parcelid, 
					propertyaddress, 
					saleprice, 
					saledate, 
					legalreference
					order by uniqueid
					) AS row_num
from nashvillehousing) AS CTE
where row_num >1;

delete from nashvillehousing
where parcelid IN(
			select parcelid
			from (
			select *,
				row_number() over(
				partition by parcelid, 
								propertyaddress, 
								saleprice, 
								saledate, 
								legalreference
								order by uniqueid
								) AS row_num
			from nashvillehousing) AS CTE
			where row_num >1
);

-- Deleting unused columns (Better not use in raw data)
Alter table nashvillehousing
drop propertyaddress, 
drop owneraddress;