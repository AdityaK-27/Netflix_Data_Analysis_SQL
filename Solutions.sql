-- Netflix Project
-- Business Problems based on this dataset

-- 1. Count the number of Movies vs TV Shows

SELECT
	type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV Shows

SELECT
	type,
	rating
FROM
(
SELECT
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1,2
) as t1
WHERE 
	ranking = 1;


-- 3. List all movies released in a specific year (eg. 2020)

	-- filter 202
	--movies
	
SELECT * FROM netflix
WHERE 
	type= 'Movie'
	AND
	release_year=2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country,
	-- we have multiple country names in a single cell
	-- use string to array to resolve this and UNNEST them to get each country in different cell(not distinct yet)
	-- trim is used to remove any whitespaces to the left or right (otherwise these usually cause error is in finding distinct values)
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT
	title,
	SUBSTRING(duration, 1, position('m' in duration)-1):: int duration
FROM netflix
WHERE 
	type='Movie'
	AND
	duration IS NOT NULL
ORDER BY 2 DESC
LIMIT 1;

-- 6. Find the content added in the last 5 years

SELECT 
	*
FROM netflix
WHERE 
	TO_Date(date_added, 'Month DD, YYYY') >= CURRENT_DATE- INTERVAL '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka' !

	--We have multiple directors in a few movies/ TV shows
	--ILIKE function ignore case of the string to be cheked (Will be treated as 'rajiv chilaka')
SELECT
	*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

	--Solution 1 (Using SUBSTRING Function)
SELECT 
	*
FROM netflix
WHERE
	type='TV Show'
	AND
	SUBSTRING(duration, 1,2):: INT > 5;

	--Solution 2 (Using SPLIT_PART Function)
SELECT 
	*
FROM netflix
WHERE
	type='TV Show'
	AND
	SPLIT_PART(duration, ' ', 1):: INT > 5;


-- 9. Count the number of content items in each genre

	--Solution 1(Using UNNEST and STRING_TO_ARRAY Functions)
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;


-- 10. Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release !

	--Subquerry return the value of total content by India over the years
	--Count(*) return the total content added in that particular year (Look at Group By carefully)
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) AS yearly_content,
	ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country='India'):: NUMERIC * 100, 2) as avg_content
FROM netflix
WHERE 
	country='India'
GROUP BY 1;


-- 11. List all the movies that are documentaries

SELECT 
	*
FROM netflix
WHERE
	type='Movie'
	AND
	listed_in ILIKE '%documentaries%';

-- 12. Find all content without a director

SELECT 
	*
FROM netflix
WHERE 
	director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT
	COUNT(*) as Salman_movies
FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) -10;

-- 14. Find the top 10 actos who have appeared in the highest number of Movies produced in India.

SELECT
	UNNEST(STRING_TO_ARRAY(casts,',')) as Actors,
	COUNT(*) AS Number_of_Movies
FROM netflix
WHERE
	type='Movie'
	AND
	Country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
	--Label content containing these keywords as 'Bad' and all other content as 'Good'. 
	--Count how many items fall into each category.

SELECT 
	CASE
	WHEN 
		description ILIKE '%Kill%'
		or
		description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END category,
	COUNT(*) as Count_of_each_Category
FROM netflix
GROUP BY 1;
