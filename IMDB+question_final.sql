USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT 
    (SELECT 
            COUNT(*)
        FROM
            movie) AS movie_num_rows,
    (SELECT 
            COUNT(*)
        FROM
            genre) AS genre_num_rows,
    (SELECT 
            COUNT(*)
        FROM
            names) AS names_num_rows,
    (SELECT 
            COUNT(*)
        FROM
            ratings) AS ratings_num_rows,
    (SELECT 
            COUNT(*)
        FROM
            role_mapping) AS role_mapping_num_rows,
    (SELECT 
            COUNT(*)
        FROM
            director_mapping) AS director_mapping_num_rows
;


-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT 
    SUM(ISNULL(title)) AS title_null_count,
    SUM(ISNULL(year)) AS year_null_count,
    SUM(ISNULL(date_published)) AS date_published_null_count,
    SUM(ISNULL(duration)) AS duration_null_count,
    SUM(ISNULL(country)) AS country_null_count,
    SUM(ISNULL(worlwide_gross_income)) AS worlwide_gross_income_null_count,
    SUM(ISNULL(languages)) AS languages_null_count,
    SUM(ISNULL(production_company)) AS production_company_null_count
FROM
    movie
;

-- Four columns of the movie table has null values: country, worlwide_gross_income, languages, production_company

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Total number movies released each year
SELECT
	year AS 'Year',
    COUNT(*) AS number_of_movies
FROM
	movie
GROUP BY
	year
ORDER BY
	year
;

-- Total number movies released by month
SELECT 
    MONTH(date_published) AS month_num,
    COUNT(*) AS number_of_movies
FROM
    movie
GROUP BY month_num
ORDER BY number_of_movies DESC
;


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT 
    COUNT(*) AS num_of_movies
FROM
    movie
WHERE
    country REGEXP 'USA|India'
        AND year = 2019
;

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT
    genre
FROM
    genre
ORDER BY genre
;


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
    genre, 
    COUNT(movie_id) AS num_of_movies
FROM
    genre g
        INNER JOIN
    movie m ON m.id = g.movie_id
GROUP BY 
	genre
ORDER BY 
	num_of_movies DESC
;


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
WITH one_genre_movies AS
(
	SELECT 
		movie_id,
        COUNT(genre) AS num_of_genre
	FROM
		genre
	GROUP BY
		movie_id
	HAVING 
		COUNT(genre) = 1
)
SELECT 
	COUNT(*) AS num_of_one_genre_movies
FROM 
	one_genre_movies;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    g.genre, 
    ROUND(AVG(duration), 2) AS avg_duration
FROM
    genre g
        INNER JOIN movie m ON m.id = g.movie_id
GROUP BY 
	g.genre
;


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH ranked_genres AS
(
	SELECT 
		g.genre,
		COUNT(*) AS movie_count,
		RANK() OVER (ORDER BY COUNT(*) DESC) AS genre_rank
	FROM 
		genre g
		INNER JOIN movie m ON m.id=g.movie_id
	GROUP BY
		g.genre
	ORDER BY
		genre_rank
)
SELECT 
	genre,
    movie_count,
    genre_rank
FROM
	ranked_genres
WHERE 
	genre = 'Thriller'
;

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings
;




    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT
	m.title,
	r.avg_rating,
	RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM
	movie m 
	INNER JOIN ratings r 
	ON r.movie_id = m.id
ORDER BY
	movie_rank
LIMIT 10
;


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
	median_rating,
    COUNT(movie_id) AS movie_count
FROM
	ratings
GROUP BY median_rating
ORDER BY movie_count DESC
;



/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT 
	m.production_company,
    COUNT(m.id) AS movie_count,
    DENSE_RANK() OVER(ORDER BY count(m.id) DESC) AS prod_company_rank
FROM
	movie m 
    INNER JOIN ratings r 
    ON r.movie_id = m.id
WHERE 
	r.avg_rating > 8 
    AND m.production_company IS NOT NULL
GROUP BY
	m.production_company
ORDER BY
	prod_company_rank
;



-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
	g.genre,
    COUNT(m.id) AS movie_count
FROM
	genre g 
    INNER JOIN movie m 
    ON m.id=g.movie_id
		INNER JOIN ratings r
        ON r.movie_id = m.id
WHERE 
	MONTH(m.date_published) = 3
    AND m.year = 2017
    AND r.total_votes > 1000
    #AND m.country LIKE '%USA%'
    AND m.country REGEXP 'USA+'
GROUP BY
	g.genre
ORDER BY
	movie_count DESC
;







-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT 
	m.title,
    r.avg_rating,
    g.genre
FROM 
	movie m 
    INNER JOIN genre g ON m.id=g.movie_id
		INNER JOIN ratings r ON r.movie_id = m.id
WHERE 
	#m.title REGEXP '^The'
    m.title LIKE 'The%'
    AND r.avg_rating > 8
ORDER BY
	r.avg_rating DESC
;



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT 
	r.median_rating,
    COUNT(m.id) AS num_of_movies
FROM 
	movie m
	INNER JOIN ratings r 
    ON r.movie_id=m.id
WHERE 
	m.date_published BETWEEN STR_TO_DATE('2018-04-01','%Y-%m-%d') AND STR_TO_DATE('2019-04-01','%Y-%m-%d')
	AND r.median_rating = 8
GROUP BY 
	median_rating
;



-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
/* --     Check by country
SELECT 
    SUM(CASE
        WHEN country REGEXP 'Germany+' THEN total_votes
        ELSE 0
    END) AS german_total_votes,
    SUM(CASE
        WHEN country REGEXP 'Italy+' THEN total_votes
        ELSE 0
    END) AS italian_total_votes
FROM
    movie m
        INNER JOIN
    ratings rt ON rt.movie_id = m.id
WHERE
    country REGEXP 'Italy|Germany'
;
*/
--     Check by languages
SELECT 
    SUM(CASE
        WHEN languages REGEXP 'German+' THEN total_votes
        ELSE 0
    END) AS german_movie_total_votes,
    SUM(CASE
        WHEN languages REGEXP 'Italian+' THEN total_votes
        ELSE 0
    END) AS italian_movie_total_votes
FROM
    movie m
        INNER JOIN
		ratings rt ON rt.movie_id = m.id
WHERE
    languages REGEXP 'Italian|German'
;

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
    SUM(ISNULL(name)) AS name_nulls,
    SUM(ISNULL(height)) AS height_nulls,
    SUM(ISNULL(date_of_birth)) AS date_of_birth_nulls,
    SUM(ISNULL(known_for_movies)) AS known_for_movies_nulls
FROM
    names
;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH top3_genres AS
(
	SELECT
		g.genre,
		count(g.movie_id) AS num_of_movies
	FROM
		genre g
		INNER JOIN ratings rt USING (movie_id)
	WHERE
		rt.avg_rating > 8
	GROUP BY 
		g.genre
	ORDER BY
		num_of_movies DESC
	LIMIT 3
)
SELECT 
	d.name,
    COUNT(DISTINCT r.movie_id) AS movie_count
FROM 
	names d
    INNER JOIN director_mapping dm ON dm.name_id = d.id
		INNER JOIN genre r ON r.movie_id = dm.movie_id
			INNER JOIN ratings rt ON rt.movie_id=r.movie_id
WHERE 
	r.genre IN (SELECT genre FROM top3_genres)
    AND rt.avg_rating > 8
GROUP BY
	d.name
ORDER BY 
    movie_count DESC
LIMIT 3
;


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    n.name, COUNT(rm.movie_id) AS movie_count
FROM
    names n
        INNER JOIN role_mapping rm 
        ON rm.name_id = n.id
			INNER JOIN ratings rt 
            ON rt.movie_id = rm.movie_id
WHERE
    rt.median_rating >= 8
	AND rm.category = 'actor'
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2
;


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
	m.production_company,
    SUM(rt.total_votes) AS vote_count,
    RANK() OVER(ORDER BY SUM(rt.total_votes) DESC) prod_comp_rank
FROM
	movie m
    INNER JOIN ratings rt 
    ON rt.movie_id = m.id
GROUP BY 
	m.production_company
ORDER BY
	prod_comp_rank
LIMIT 3
;



/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH indian_actors AS
(
	SELECT 
		n.name AS actor_name,
		SUM(rt.total_votes) AS total_votes,
		COUNT(rm.movie_id) AS movie_count,
		ROUND(SUM(rt.avg_rating*rt.total_votes)/SUM(rt.total_votes),2) AS actor_avg_rating
	FROM
		names n 
		INNER JOIN role_mapping rm ON rm.name_id = n.id
			INNER JOIN movie m on m.id=rm.movie_id 
				INNER JOIN ratings rt ON rt.movie_id = m.id
	WHERE 
		#m.country REGEXP 'India+'
        m.country LIKE '%India%'
		AND rm.category = 'actor'
	GROUP BY
		n.name
)
SELECT
	actor_name,
    total_votes,
    movie_count,
    actor_avg_rating,
    RANK() OVER(ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM 
	indian_actors
WHERE 
	movie_count >=5
;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH indian_actresses AS
(
	SELECT 
		n.name,
		SUM(rt.total_votes) AS total_votes,
		COUNT(rm.movie_id) AS movie_count,
		ROUND(SUM(rt.avg_rating*rt.total_votes)/SUM(rt.total_votes),2) AS actress_avg_rating
	FROM
		names n 
		INNER JOIN role_mapping rm ON rm.name_id = n.id
			INNER JOIN movie m on m.id=rm.movie_id 
				INNER JOIN ratings rt ON rt.movie_id = m.id
	WHERE 
		m.country REGEXP 'India+'
		AND rm.category = 'actress'
        AND m.languages REGEXP 'Hindi+'
	GROUP BY
		n.name
)
SELECT
	name,
    total_votes,
    movie_count,
    actress_avg_rating,
    RANK() OVER(ORDER BY actress_avg_rating DESC, total_votes DESC) AS actress_rank
FROM 
	indian_actresses
WHERE 
	movie_count >= 3
;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT 
	m.title,
	r.genre,
	rt.avg_rating,
	(CASE 
		WHEN rt.avg_rating > 8 THEN 'Superhit movies'
		WHEN rt.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
		WHEN rt.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
		ELSE 'Flop movies'
	END) AS rating_group
FROM 
	movie m
	INNER JOIN genre r ON r.movie_id = m.id
		INNER JOIN ratings rt ON rt.movie_id = m.id
WHERE
	r.genre = 'Thriller'
;

--    Find number of movies in each group
WITH rating_group_details AS
(
	SELECT 
		m.id,
		(CASE 
			WHEN rt.avg_rating > 8 THEN 'Superhit movies'
			WHEN rt.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
			WHEN rt.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
			ELSE 'Flop movies'
			END) AS rating_group
	FROM 
		movie m
		INNER JOIN genre r ON r.movie_id = m.id
			INNER JOIN ratings rt ON rt.movie_id = m.id
	WHERE
		r.genre = 'Thriller'
)
SELECT 
	rating_group,
    count(*) AS num_of_movies
FROM
	rating_group_details
GROUP BY 
	rating_group
;


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

WITH genres AS
(
	SELECT 
		genre,
		AVG(duration) AS avg_duration,
		SUM(AVG(duration)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
		AVG(AVG(duration)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS moving_avg_duration
	FROM 
		movie m 
		INNER JOIN genre g 
		ON m.id= g.movie_id
	GROUP BY genre
)
SELECT 
	genre,
	ROUND(avg_duration,2) AS avg_duration,
	ROUND(running_total_duration,2) AS running_total_duration,
	ROUND(moving_avg_duration,2) AS moving_avg_duration
FROM
	genres
ORDER BY 
	genre
;


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top3_genres AS
(
	SELECT
		genre, 
        COUNT(movie_id) AS num_of_movies
	FROM
		genre
	GROUP BY
		genre
	ORDER BY
		count(movie_id) DESC
	LIMIT 3
), movie_ranking_details AS
(
	SELECT 
			g.genre,
			m.year,
			m.title AS movie_name,
			worlwide_gross_income AS worldwide_gross_income, 
			DENSE_RANK() OVER w AS movie_rank
		FROM 
			genre g 
			INNER JOIN movie m ON m.id = g.movie_id
		WHERE
			g.genre IN (SELECT genre FROM top3_genres)
		WINDOW w AS 
			(
				PARTITION BY m.year 
				ORDER BY 
					 (
						CASE 
							WHEN POSITION('$' IN worlwide_gross_income) > 0 THEN CAST(REPLACE(worlwide_gross_income,'$','') AS DECIMAL(10))
							WHEN POSITION('INR' IN worlwide_gross_income) > 0 THEN CAST(REPLACE(worlwide_gross_income,'INR','') AS DECIMAL(10))*0.012 
							ELSE 0
						END
					 ) DESC
			)
)
SELECT *
FROM movie_ranking_details
WHERE
	movie_rank <=5
ORDER BY
    year,
    movie_rank
;
-- Top 3 Genres based on most number of movies


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
	m.production_company,
    COUNT(m.id) AS movie_count,
    RANK() OVER (ORDER BY COUNT(m.id) DESC) AS prod_comp_rank
FROM 
	movie m 
    INNER JOIN ratings r ON r.movie_id = m.id
WHERE
	-- m.languages REGEXP ',+'
    POSITION(',' IN languages) > 0
    AND r.median_rating >= 8
    AND m.production_company IS NOT NULL
GROUP BY
	m.production_company
ORDER BY 
	prod_comp_rank
LIMIT 2
;


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actresses AS
(
	SELECT 
		n.name AS actress_name,
		SUM(rt.total_votes) AS total_votes,
		COUNT(rm.movie_id) AS movie_count,
		ROUND(SUM(rt.avg_rating*rt.total_votes)/SUM(rt.total_votes),2) AS actress_avg_rating
	FROM
		names n 
		INNER JOIN role_mapping rm ON rm.name_id = n.id
			INNER JOIN movie m on m.id=rm.movie_id 
				INNER JOIN ratings rt ON rt.movie_id = m.id
					INNER JOIN genre g ON g.movie_id = m.id 
	WHERE 
		rt.avg_rating > 8
        AND rm.category = 'actress'
        AND g.genre = 'Drama'
	GROUP BY
		n.name
)
SELECT
	actress_name,
    total_votes,
    movie_count,
    actress_avg_rating,
    RANK() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM 
	actresses
ORDER BY 
	actress_rank
LIMIT 3
;


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH directors AS
(
	SELECT
		n.id AS director_id,
		n.name AS director_name,
        m.id AS movie_id,
		m.duration,
		r.avg_rating,
		r.total_votes,
		m.date_published,
		LAG(m.date_published) OVER W AS pre_date_published
	FROM 
		names n 
		INNER JOIN director_mapping dm ON dm.name_id = n.id
			INNER JOIN movie m ON m.id=dm.movie_id
				INNER JOIN ratings r ON r.movie_id = m.id
	WINDOW w AS (PARTITION BY n.id, n.name ORDER BY m.date_published)
)
SELECT
	director_id,
	director_name,
    COUNT(movie_id) AS number_of_movies,
    ROUND(avg(DATEDIFF(date_published, pre_date_published)),2) AS avg_inter_movie_days,
    ROUND(avg(avg_rating),2) AS avg_rating,
    SUM(total_votes) AS total_votes,
	MIN(avg_rating) AS min_rating,
	MAX(avg_rating) AS max_rating,
	SUM(duration) AS total_duration
FROM directors
GROUP BY
	director_id,
	director_name
ORDER BY number_of_movies DESC
LIMIT 9
;






