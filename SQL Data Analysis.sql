/*

-------------------------------SQL Capstone Project-----------------------------------------------
Business problem: 
To gain insight into the sales data of Amazon to understand the different factors that affect sales of the different branches.

Objective: 
To analyze Amazon's sales data to identify key factors influencing sales performance across different branches,
enabling data-driven decision-making to optimize revenue and operational efficiency.

Challenges:
1. Ensuring access to complete, accurate, and up-to-date sales data across all branches.
2. Combining data from multiple sources (e.g., online vs. offline sales, different product categories) for comprehensive analysis.
3. Understanding how sales trends differ based on location
4. Identifying patterns in customer preferences and their impact on sales performance.

Future Scope: 
1. Integrate social media, customer reviews, and competitor analysis to gain deeper market insights.
2. Implement dynamic pricing algorithms based on demand, competition, and customer behavior.
3. Compare sales data across branches to identify best practices and areas for improvement.
4. Analyze customer feedback and reviews to understand product preferences and enhance user experience.
5. Promote eco-friendly practices, optimize packaging, and reduce carbon footprint in supply chain operations.

Data Wrangling
1. Creating a database name - amazon_analysis
2. Importing the dataset using the Table data import Wizard
3. Checking if the database has any null values the null values
There are 1000 rows and 17 columns in the dataset. 

*/

# Creating a database
create database amazon_analysis;

# Selecting the databse for further usage
use amazon_analysis;

# Getting basics insights from the table
select * from amazon;

/* Feature Engineering
1. Adding a new column named 'timeofday' to provide insight into which 
   part of the day most sales are made.
*/
alter table amazon add column timeofday varchar(20);
update amazon
set timeofday = 
    case 
        when hour(Time) between 6 and 11 then 'Morning'
        when hour(Time) between 12 and 17 then 'Afternoon'
        when hour(Time) between 18 and 23 then 'Evening'
    end;
    
    
# Exploratory Data Analysis

select distinct(city) from amazon;
# 1. count of distinct cities in the dataset
# There are three cities - Yangon, Naypyitaw, Mandalay


select distinct branch, city from amazon;
/*2. Corresponding city For each branch
A	Yangon
C	Naypyitaw
B	Mandalay
*/

# Product Analysis
select count(distinct `product line`) from amazon; #6 
select distinct(`product line`) from amazon;
/* 3. There are 6 distinct product lines in the dataset.
Health and beauty
Electronic accessories
Home and lifestyle
Sports and travel
Food and beverages
Fashion accessories
*/ 

# 4. Which payment method occurs most frequently?
select payment, count(*) as frequency
from amazon 
group by payment
order by frequency desc
limit 1;
/* E- wallet is used more frequently - 345
 Cash is equivalently used - 344
 Credit card is less used - 311 */
 
# 5. Which product line has the highest sales?
select `product line`, round(sum(total),2) AS total_sales
from amazon
group by `product line`
order by total_sales desc
limit 1;
/* 
Food and beverages	56144.844000000005
Sports and travel	55122.826499999996
Electronic accessories	54337.531500000005
Fashion accessories	54305.895
Home and lifestyle	53861.91300000001
Health and beauty	49193.739000000016
*/

# 6. How much revenue is generated each month?
select date_format(date, '%Y-%m') as month, 
       round(sum(total), 2) as total_revenue
from amazon
group by month
order by month;
/* 
January month has the higest revenue - 1,16,291.87
February month has revenue of - 97219.37
March month has revenue of - 109455.51
*/

# 7. In which month did the cost of goods sold reach its peak?
select date_format(date, '%Y-%m') as month, 
       round(sum(cogs), 2) as total_cogs
from amazon
group by month
order by total_cogs desc;
/*
January month has the highest  cost of goods sales - 110754
Febrary month has the lowest COGS sales - 92589.88
COGS sale of March is - 104243.34
*/

# 8. Which product line generated the highest revenue?
select `product line`, round(sum(total), 2) as total_revenue
from amazon
group by `product line`
order by total_revenue desc;
/*
Food and beverages-56144.84
Sports and travel - 55122.83
Electronic accessories - 54337.53
Fashion accessories - 54305.9
Home and lifestyle - 53861.91
Health and beauty - 49193.74
*/

#9. In which city was the highest revenue recorded?
select city, round(sum(total), 2) AS total_revenue
from amazon
group by city
order by total_revenue desc;
/*
Naypyitaw has the highest revenue - 110568.71
Yangon has a revenue of - 106200.37
Mandalay has the lowest revenue - 106197.67
*/

# 10. Which product line incurred the highest Value Added Tax?
select `product line`, round(sum(`Tax 5%`), 2) as total_VAT
from amazon
group by `product line`
order by total_VAT desc; 
/* Food and beverages incurred the highest vat value out of all the product line
Food and beverages -> 2673.56
Sports and travel -> 2624.9
Electronic accessories -> 2587.5
Fashion accessories	-> 2586
Home and lifestyle -> 2564.85
Health and beauty -> 2342.56
*/

# 11. For each product line, adding a column indicating "Good" if its sales are above average, otherwise "Bad."
select `product line`, round(sum(total),2) as total_sales,
case
	when sum(total) > (Select avg(total) from amazon) then 'Good'
    else 'Bad'
end as sales_performance
from amazon
group by `product line`;
# All the product lines are having good sales performance


# 12. Identify the branch that exceeded the average number of products sold.
select branch, sum(quantity) as total_products_sold
from amazon
group by branch
having total_products_sold > (select avg(total_quantity) 
                              from (select sum(quantity) as total_quantity from amazon group by branch) as avg_table);
# Branch A exceeds the average number of products sold


# 13. Which product line is most frequently associated with each gender?
select gender, `product line`, count(*) as purchase_count
from amazon
group by gender, `product line`
having purchase_count = (
    select max(purchase_count) 
    from (select gender, `product line`, count(*) as purchase_count 
          from amazon  
          group by gender, `product line`) as subquery
    where subquery.gender = amazon.gender
);
/* Male	most frequently purchased is in Health and beauty (88)
Female most frequently purchased products is in Fashion accessories (96)
*/

# 14. Calculate the average rating for each product line.
select `product line`, round(avg(rating), 2) as average_rating
from amazon
group by `product line`
order by average_rating desc;
/* The average rating for each product line is as below
Food and beverages -> 7.11
Fashion accessories	-> 7.03
Health and beauty -> 7
Electronic accessories -> 6.92
Sports and travel -> 6.92
Home and lifestyle -> 6.84
*/

# Sales Analysis
# 15. Count the sales occurrences for each time of day on every weekday
select dayname(date) as weekday, timeofday, count(*) as sales_count
from amazon
group by weekday, timeofday
order by FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), timeofday desc;
# Wednesday and saturday Afternoon there is highest sales - with count 81
# Monday morning has the lowest sales

# 16. Identify the customer type contributing the highest revenue.
select `customer type`, ROUND(SUM(total), 2) as total_revenue
from amazon
group by `customer type`
order by total_revenue desc;
# Member customer type has the highest sales - 164223.44
# Normal customer type has the lowest sales - 158743.31

# 17. Determine the city with the highest VAT percentage.
select city, ROUND(AVG(`Tax 5%`/ total * 100), 2) AS avg_vat_percentage
FROM amazon
WHERE total > 0  -- To avoid division by zero
GROUP BY city
ORDER BY avg_vat_percentage DESC;
/* All the three cities have the same VAT percentage
Yangon - 4.76
Naypyitaw - 4.76
Mandalay - 4.76
*/

# 18. Identify the customer type with the highest VAT payments.
select `customer type`, round(sum(`Tax 5%`), 2) as total_vat_paid
from amazon
group by `customer type`
order by total_vat_paid desc;
/* Member customer type paid the highest VAT
where as Normal customer type paid lower that the members */

# Customer Analysis
#19. What is the count of distinct customer types in the dataset?
select  count(distinct `customer type`) as no_of_customer_type from amazon;
# There are 2 distinct types of customer types namely - Member and normal

# 20. What is the count of distinct payment methods in the dataset?
select count(distinct payment) as No_of_payment_method from amazon;
# There are 3 payment methods namely - Ewallet, Cash and Credit card

# 21. Which customer type occurs most frequently?
select `customer type`, count(*) as customer_frequency
from amazon
group by `customer type`
order by customer_frequency desc;
# Member customer type occurs most than Normal customer type

# 22. Identify the customer type with the highest purchase frequency.
select `customer type`, count(*) as purchase_frequency
from amazon
group by `customer type`
order by purchase_frequency desc;
# Member customer type has the highest purchase frequency than normal customer type

# 23. Determine the predominant gender among customers.
select gender, count(*) as customer_count
from amazon
group by gender
order by customer_count desc;
# female are more predominant among customer than male. 

# 24. Examine the distribution of genders within each branch.
select branch, gender, COUNT(*) as customer_count
from amazon
group by branch, gender
order by branch, customer_count desc;
# Branch A and B has more male customers than females where as branch C has more female customers than male.

# 25. Identify the time of day when customers provide the most ratings.
select timeofday, COUNT(rating) as rating_count
from amazon
group by timeofday
order by rating_count desc;
/* Customers mostly prefer to give raatings in the afternoon
Afternoon -> 528
Evening -> 	281
Morning -> 191
*/

# 26. Determine the time of day with the highest customer ratings for each branch.
select timeofday, branch, count(rating) as rating_count
from amazon
group by timeofday, branch
order by branch;
# Branch A(185), B(162) and C(181) all three branches have highest ratings in the afternoon. 

# 27. Identify the day of the week with the highest average ratings.
select dayname(date) AS weekday, round(avg(rating), 2) as avg_rating
from amazon
group by weekday
order by avg_rating desc;
# Monday is the day of week with highest average rating

# 28. Determine the day of the week with the highest average ratings for each branch.
select branch, dayname(date) AS weekday, round(avg(rating), 2) as avg_rating
from amazon
group by branch, weekday
order by branch;
/* Branch A and C have highest average ratings of 7.31 and 7.28 respectively on Fridays 
where as Branch B has highest average ratings of 7.34 on Monday.
Branch A has lowest average ratings of 6.75 on Saturday.
Branch B has lowest average ratings of 6.45 on Wednesdays.
Branch C has lowest average rating of 6.95 on Tuesdays and Thursdays.
Out of all the three branches B has the lowest average ratings.
*/

