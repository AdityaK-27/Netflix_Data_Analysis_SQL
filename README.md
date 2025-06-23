# Netflix Data Analysis using SQL

![](https://github.com/AdityaK-27/Netflix_Data_Analysis_SQL/blob/main/logo.png)

## Overview
This project dives into Netflix’s content catalog to perform an in-depth analysis using SQL. The aim is to uncover patterns, trends, and insights related to the platform’s Movies and TV Shows. The following sections detail the project’s goals, the questions explored, methods used, and key takeaways from the analysis.

## Objectives

- Study how content is distributed between Movies and TV Shows.
- Discover which ratings appear most often across different content types.
- Investigate trends based on release year, country of origin, and duration.
- Classify content using keyword-based logic to extract targeted insights.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
CREATE TABLE netflix
(
	show_id	VARCHAR(6),
	type 	VARCHAR(10),
	title 	VARCHAR(150),
	director	VARCHAR(208),
	casts	VARCHAR(1000),
	country	VARCHAR(150),	
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT
	type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * FROM netflix
WHERE 
	type= 'Movie'
	AND
	release_year=2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
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
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
	*
FROM netflix
WHERE 
	TO_Date(date_added, 'Month DD, YYYY') >= CURRENT_DATE- INTERVAL '5 years'
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT
	*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
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
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
--Solution 1(Using UNNEST and STRING_TO_ARRAY Functions)
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release !

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT 
	*
FROM netflix
WHERE
	type='Movie'
	AND
	listed_in ILIKE '%documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT 
	*
FROM netflix
WHERE 
	director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT
	COUNT(*) as Salman_movies
FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) -10;

```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15.  Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

* **More Movies than Shows**
  - The data shows that Netflix hosts more movies than TV shows.
  - This suggests the platform leans more towards one-off content rather than episodic series.

* **Most Common Ratings**
  - TV-MA and TV-14 are the most frequent ratings.
  - This indicates that Netflix mainly targets mature teens and adult viewers.

* **Top Countries & India’s Role**
  - The US, India, and the UK contribute the most content to Netflix.
  - Content from India has grown in recent years, showing an increase in regional production.

* **Popular Genres**
  - Drama, International Movies, and Comedies are the most listed genres.
  - This aligns with Netflix’s global strategy to offer content for a wide range of tastes.

* **Longer Series & Movies**
  - I identified the longest movie and filtered out TV shows with more than 5 seasons.
  - This points to Netflix's investment in long-form content that encourages binge-watching.

* **Keyword-Based Content Categorization**
  - By checking for keywords like “kill” and “violence” in descriptions, content was labeled as either ‘Bad’ or ‘Good’.
  - This simple categorization gives insight into the presence of intense or violent content.

* **Director & Actor Highlights**
  - I listed all content by directors like Rajiv Chilaka.
  - Also found the top 10 actors who appear most often in Indian movies on Netflix.

* **Cleaning & Processing Techniques**
  - Used SQL functions like `UNNEST`, `SPLIT_PART`, and `STRING_TO_ARRAY` to break down multi-valued columns.
  - This made the data easier to clean, filter, and analyze effectively.

---

Overall, this project helped me practice advanced SQL techniques and understand how to extract useful business insights from real-world datasets. It reflects the kind of work a data analyst might do when exploring platform performance and content strategy.
