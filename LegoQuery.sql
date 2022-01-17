--Inventory sets with quantites 7,5,3 the version
select ins.inventory_id, ins.set_num, quantity, i.version from inventory_sets as ins
join inventories i on i.id = ins.inventory_id
where ins.quantity IN (7,5,3)

--Query joining from inventories to themes
select s.name as 'Set Name', i.id, i.version, i.set_num, s.year, s.theme_id, s.num_parts, t.parent_id, t.name as 'Theme Name' from inventories as i
join sets s on s.set_num = i.set_num
join themes t on t.id = s.theme_id
order by Year, i.set_num

--Second highest num_parts
select s.name as 'Set Name', i.id, i.version, i.set_num, s.year, s.theme_id, s.num_parts, t.parent_id, t.name as 'Theme Name' from inventories as i
join sets s on s.set_num = i.set_num
join themes t on t.id = s.theme_id
order by num_parts desc offset 1 rows fetch next 1 rows only

--Filter on rbg value or colors blue and black
select p.name as 'Parts name', pc.name as 'Category Name', c.name as 'Color', inp.part_num, c.rgb
from inventory_parts inp
join parts p on inp.part_num = p.part_num
join part_categories pc on pc.id = p.part_cat_id
join colors c on c.id = inp.color_id
where rgb = '05131D' or c.name like 'B%'

-- Second highest num_parts partitioned by theme id
with cte as(select name, year, num_parts, theme_id,
DENSE_RANK() OVER(Partition by theme_id order by num_parts desc)rn
from sets)
select * from cte
where rn = 2

--Lego sets partitioned by theme_id and second latest release
with cte as(select name, year, num_parts, theme_id,
DENSE_RANK() OVER(Partition by theme_id order by year desc)rn
from sets)
select * from cte
where rn = 2

--Unique lego sets name 
select Distinct(name)
from sets

--Finding duplicate names in sets
Drop table if exists #dups
select name, count(*) as cnt
into #dups
from sets
group by name
Having Count(*) > 1

--The newest sets that have duplicate names
select s.name, MAX(Year) from #dups d
join sets s on s.name = d.name
Group by s.name

--The sets with the name 2-Stud Axles with Grooves (Pack of 100) order by year
select * from sets 
where name like '2-Stud Axles with Grooves (Pack of 100)'
order by year desc

