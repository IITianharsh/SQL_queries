create database tourists;
show tables;
select * from tourists.domestic_visitors;

/* q1->list top 10 district with highest no. of domestic footfall overall?*/

select distinct district, sum(visitors) as total_visitors from domestic_visitors
group by district
order by total_visitors desc
limit 10;

-- another approach with cte
WITH CTE1 AS
     (
     SELECT District , SUM(visitors) AS Total_Visitors,
     CONCAT(FORMAT(SUM(visitors)/1000000,'m'),' ','M') AS 'Total_in_Million'
     FROM domestic_visitors
     GROUP BY district
     )
SELECT District,Total_Visitors,Total_in_Million,
RANK() OVER ( ORDER BY total_visitors DESC ) AS 'Rank'
FROM CTE1
LIMIT 10;

/*list down top 3 district based on compounded annual growth rate of visitors between 2016-2019




*/
SELECT district,
  CONCAT(((POWER(total_visitors_2019/total_visitors_2016, 1.0/3) - 1) * 100),'%')  AS growth_rate
FROM (
  SELECT district,
    SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS total_visitors_2016,
    SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS total_visitors_2019
  FROM domestic_visitors
  WHERE year BETWEEN 2016 AND 2019
  GROUP BY district
) AS district_totals
ORDER BY growth_rate desc
LIMIT 3;

/*q3. list down bottom 3 based on cagr*/

--

WITH district_totals AS (
  SELECT district,
    SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS total_visitors_2016,
    SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS total_visitors_2019
  FROM domestic_visitors
  GROUP BY district
)
SELECT district,
  POWER(total_visitors_2019/total_visitors_2016, 1.0/3) - 1 AS growth_rate
FROM district_totals
group by district
having growth_rate is not null
-- where   (POWER(total_visitors_2019/total_visitors_2016, 1.0/3) - 1)<0
ORDER BY growth_rate asc
LIMIT 3;

/* write to find what are the peak and low seasons month for hyderabad*/

SELECT district, month, MAX(visitors) AS visitor_max
FROM domestic_visitors
WHERE district = 'Hyderabad'
GROUP BY district, month
ORDER BY visitor_max DESC
LIMIT 3;


select district,month,MIN(visitors) as visitor_min
from domestic_visitors
where district='Hyderabad'
group by month
order by visitor_min asc limit 3;


/* wrtie a query to show ratio of top and bottom 3 districts from domestic and foreign*/

select * from domestic_visitors;
select * from foreign_visitors;
-- using cte
WITH district_totals AS (
  SELECT district,
         SUM(CASE WHEN table_type = 'domestic' THEN visitors ELSE 0 END) AS domestic_visitors,
         SUM(CASE WHEN table_type = 'foreign' THEN visitors ELSE 0 END) AS foreign_visitors
  FROM (
    SELECT district, 'domestic' AS table_type, visitors
    FROM domestic_visitors
    UNION ALL
    SELECT district, 'foreign' AS table_type, visitors
    FROM foreign_visitors
  ) AS combined_visitors
  GROUP BY district
),
ranked_districts AS (
  SELECT district,
         domestic_visitors,
         foreign_visitors,
         domestic_visitors / NULLIF(foreign_visitors, 0) AS ratio,
         ROW_NUMBER() OVER (ORDER BY (domestic_visitors / NULLIF(foreign_visitors, 0)) DESC) AS rank_desc,
         ROW_NUMBER() OVER (ORDER BY (domestic_visitors / NULLIF(foreign_visitors, 0)) ASC) AS rank_asc
  FROM district_totals
)
SELECT district, domestic_visitors, foreign_visitors, ratio
FROM ranked_districts
WHERE rank_desc <= 3 OR rank_asc <= 3
ORDER BY ratio DESC;

-- another approach

WITH CTE1 AS
     (
     SELECT d.district AS DD,f.district AS FF, sum(d.visitors)/sum(f.visitors) AS Ratio
     FROM domestic_visitors d JOIN foreign_visitors f
     ON d.district = f.district
     GROUP BY d.district,f.district
     ORDER BY ratio DESC
     LIMIT 3
     ),
CTE2 AS
     (
     SELECT d.district AS DD,f.district AS FF, sum(d.visitors)/sum(f.visitors) AS Ratio
     FROM domestic_visitors d JOIN foreign_visitors f
     ON d.district = f.district
     WHERE f.visitors > 0
     GROUP BY d.district,f.district
     ORDER BY ratio ASC
     LIMIT 3
     )
SELECT DD AS District,'High' AS Type, Ratio FROM cte1
UNION
SELECT DD AS District,'Low' AS Type, Ratio FROM cte2;



/* Write a sql query to list the top and bottom 5 district based on population to tourist footfall ratio in 2019  */

WITH district_ratios AS (
  SELECT d.district, SUM(visitors) / NULLIF(SUM(population), 0) AS ratio,
         ROW_NUMBER() OVER (ORDER BY (SUM(visitors) / NULLIF(SUM(population), 0)) DESC) AS rank_desc,
         ROW_NUMBER() OVER (ORDER BY (SUM(visitors) / NULLIF(SUM(population), 0)) ASC) AS rank_asc
  FROM (
    SELECT district, visitors
    FROM domestic_visitors
    WHERE year = 2019
    UNION ALL
    SELECT district, visitors
    FROM foreign_visitors
    WHERE year = 2019
  ) AS combined_visitors
  JOIN residents_population USING (district)
  GROUP BY district
)
SELECT district, ratio
FROM district_ratios
WHERE rank_desc <= 5
ORDER BY ratio DESC

UNION ALL

SELECT district, ratio
FROM district_ratios
WHERE rank_asc <= 5
ORDER BY ratio ASC;


/*write a sql query to find the projected number of foreign and domestic tourist  in hyderabad based on growth rate from presvious years*/

WITH 
    domestic_growth_rates AS (
        SELECT 
            district, 
            year, 
            AVG(visitors) AS avg_visitors, 
            (AVG(visitors) - LAG(AVG(visitors)) OVER (PARTITION BY district ORDER BY year)) / LAG(AVG(visitors)) OVER (PARTITION BY district ORDER BY year) AS growth_rate
        FROM 
            domestic_visitors
        WHERE 
            district = 'Hyderabad'
        GROUP BY 
            district, year
    ),
    foreign_growth_rates AS (
        SELECT 
            district, 
            year, 
            AVG(visitors) AS avg_visitors, 
            (AVG(visitors) - LAG(AVG(visitors)) OVER (PARTITION BY district ORDER BY year)) / LAG(AVG(visitors)) OVER (PARTITION BY district ORDER BY year) AS growth_rate
        FROM 
            foreign_visitors
        WHERE 
            district = 'Hyderabad'
        GROUP BY 
            district, year
    )
SELECT 
    'Hyderabad' AS district,
    domestic.avg_visitors * POWER(1 + domestic.growth_rate, 1) AS projected_domestic_visitors,
    foreign_visitors.avg_visitors * POWER(1 + foreign_visitors.growth_rate, 1) AS projected_foreign_visitors
FROM 
    domestic_growth_rates AS domestic
    JOIN foreign_growth_rates AS foreign_visitors
        ON domestic.district = foreign_visitors.district
        AND domestic.year = foreign_visitors.year;
        
        
/* find which district has highest potential for tourism*/

SELECT 
    district, 
    AVG(visitors) AS avg_visitors 
FROM 
    (SELECT district, visitors FROM domestic_visitors 
     UNION ALL 
     SELECT district, visitors FROM foreign_visitors) AS all_visitors 
GROUP BY 
    district 
ORDER BY 
    avg_visitors DESC 
LIMIT 
    1;

/*what kind of cultural corporate events can be conducted to boost tourism in which month and which district */

select distinct d.district,max(d.visitors) as maxim , max(f.visitors) as faxim from domestic_visitors as d join foreign_visitors as f
on d.district=f.district
group by district 
order by maxim desc, faxim desc limit 3;

/*another approach*/
SELECT 
    district, month, 
    SUM(CASE WHEN visitors > AVG(visitors) THEN 1 ELSE 0 END) AS high_visitors, 
    SUM(CASE WHEN visitors < AVG(visitors) THEN 1 ELSE 0 END) AS low_visitors 
FROM 
    (SELECT district, month, visitors FROM domestic_visitors 
     UNION ALL 
     SELECT district, month, visitors FROM foreign_visitors) AS all_visitors 
WHERE 
    district = 'Hyderabad' 
    AND month = 'june' 
GROUP BY 
    district, month;

