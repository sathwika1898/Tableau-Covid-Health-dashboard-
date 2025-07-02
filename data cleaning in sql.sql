
SELECT * FROM project1..NASHVILLEHOUSINGDATA;

---UPDATE DATEFORMAT

SELECT SALESDATECONVERTED,CONVERT(DATE,SALEDATE)
FROM PROJECT1..NASHVILLEHOUSINGDATA;


UPDATE PROJECT1..NASHVILLEHOUSINGDATA
SET SALEDATE=CONVERT(DATE,SALEDATE);

ALTER TABLE PROJECT1..NASHVILLEHOUSINGDATA
ADD SALESDATECONVERTED DATE;

UPDATE PROJECT1..NASHVILLEHOUSINGDATA
SET SALESDATECONVERTED=CONVERT(DATE,SALEDATE);

---populate property address

select propertyaddress 
FROM project1..NASHVILLEHOUSINGDATA
where propertyaddress is null;

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,isnull(a.propertyaddress,b.propertyaddress)
from project1..NASHVILLEHOUSINGDATA as a
join project1..NASHVILLEHOUSINGDATA as b
on a.parcelid=b.parcelid and
a.uniqueid<>b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from project1..NASHVILLEHOUSINGDATA as a
join project1..NASHVILLEHOUSINGDATA as b
on a.parcelid=b.parcelid and
a.uniqueid<>b.uniqueid
where a.propertyaddress is null


---split address into address and city

select propertyaddress,
substring(propertyaddress,1,charindex(',',propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyAddress)) as city
from project1..NASHVILLEHOUSINGDATA;


alter table project1..NASHVILLEHOUSINGDATA
add propertyaddresssplit nvarchar(255)

update project1..NASHVILLEHOUSINGDATA
set propertyaddresssplit=substring(propertyaddress,1,charindex(',',propertyaddress)-1)

alter table project1..NASHVILLEHOUSINGDATA
add propertycitysplit nvarchar(255)

update project1..NASHVILLEHOUSINGDATA
set propertycitysplit=substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyAddress));

select * from project1..NASHVILLEHOUSINGDATA;


---split owneraddress using parsename


select owneraddress from project1..NASHVILLEHOUSINGDATA;


alter table project1..NASHVILLEHOUSINGDATA
add owneraddresssplit varchar(255)

update project1..NASHVILLEHOUSINGDATA
set owneraddresssplit=parsename(replace(owneraddress,',','.'),3);

alter table project1..NASHVILLEHOUSINGDATA
add ownercitysplit varchar(255)

update project1..NASHVILLEHOUSINGDATA
set ownercitysplit=parsename(replace(owneraddress,',','.'),2);

alter table project1..NASHVILLEHOUSINGDATA
add ownerstatesplit varchar(255)

update project1..NASHVILLEHOUSINGDATA
set ownerstatesplit=parsename(replace(owneraddress,',','.'),1);



---change y to yes and n to no in soldasvacant

select distinct(soldasvacant),count(soldasvacant)
from project1..NASHVILLEHOUSINGDATA
group by soldasvacant

select soldasvacant,
case when soldasvacant='y' then 'yes'
	 when soldasvacant='n' then  'no'
	 else soldasvacant
	 end
from project1..NASHVILLEHOUSINGDATA

update project1..NASHVILLEHOUSINGDATA
set soldasvacant=case when soldasvacant='y' then 'yes'
	 when soldasvacant='n' then  'no'
	 else soldasvacant
	 end

---duplicate data

with cte as
(
select *,
ROW_NUMBER() over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by uniqueid) as row_num
from project1..NASHVILLEHOUSINGDATA
)
delete from cte
where row_num>1


---unused tables

select * from project1..NASHVILLEHOUSINGDATA

alter table project1..NASHVILLEHOUSINGDATA
drop column propertyaddress,saledate,owneraddress,taxdistrict;