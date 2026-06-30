use churn_db;

select count(*) from bigbasket_products;
describe bigbasket_products;
drop table bigbasket_products;

select * from bigbasket_products;
describe bigbasket_products;
-- check duplicates values
select Id , count(Id) as total_values from 
bigbasket_products 
group by Id having count(Id) >1;

select * from bigbasket_products;
-- P1
-- Data cleaning — nulls, duplicates, price anomalies fix karo
select 
sum(case when product is null then 1 else 0 end ) as product_null,
sum( case when category is null then 1 else 0 end ) as category_null,
sum(case when sub_category is null then 1 else 0 end) as sub_ca_null,
sum(case when brand is null then 1 else 0 end) as brand_null,
sum(case when sale_price is null then 1 else 0 end) as sale_price ,
sum(case when market_price is null then 1 else 0 end)as market_price,
sum(case when type is null then 1 else 0 end) as type
from bigbasket_products;

delete from bigbasket_products
where brand is null ;

select brand from bigbasket_products
where brand is null ;
-- price anamoliese
SELECT *
FROM bigbasket_products
WHERE sale_price > market_price;

-- P2
-- Category-wise average pricing aur discount analysis
select category, round(avg(sale_price),2) as avg_price, round(avg(market_price-sale_price),2)as discount_avg from bigbasket_products
group by category order by round(avg(sale_price),2) desc;

select * from bigbasket_products;
-- Brand performance — top 20 brands by product count aur avg rating
select brand, count(Id) as product_count, round(avg(rating),2) as avg_rating from bigbasket_products
group by brand order by count(Id) desc limit 20;


-- P4
-- Price tier segmentation — Budget, Mid-range, Premium products ka breakdown
select * from bigbasket_products;
SELECT *,
       CASE
           WHEN sale_price < 100 THEN 'Budget'
           WHEN sale_price BETWEEN 100 AND 500 THEN 'Mid-range'
           ELSE 'Premium'
       END AS price_tier
FROM bigbasket_products;

-- P5
-- Sub-category deep dive — kaunse sub-categories mein competition highest hai?
select sub_category , count(Id) as Total_occur from  bigbasket_products
group by sub_category order by 2 desc;


-- Discount pattern analysis — kaunsa type of product sabse zyada discount pe milta hai?
select  type, round(sum(market_price-sale_price),2) as discount from bigbasket_products

group by  type order by sum(market_price-sale_price) desc ;

-- Window function — brand rank by category based on avg rating
WITH brand_rank AS (
    SELECT brand,
           category,
           ROUND(AVG(rating),2) AS avg_rating
    FROM bigbasket_products
    GROUP BY brand, category
)
SELECT *,
       RANK() OVER(
           PARTITION BY category
           ORDER BY avg_rating DESC
       ) AS brand_ranking
FROM brand_rank;


-- P10
-- Private label analysis — BigBasket brand vs other brands comparison
SELECT
    CASE
        WHEN brand IN (
            'bb Royal',
            'bb Popular',
            'Fresho',
            'Tasties',
            'GoodDiet'
        )
        THEN 'Private Label'
        ELSE 'Other Brands'
    END AS brand_type,

    COUNT(*) AS total_products,

    ROUND(AVG(rating),2) AS avg_rating,

    ROUND(AVG(sale_price),2) AS avg_sale_price,

    ROUND(
        AVG(
            ((market_price - sale_price) * 100.0)
            / market_price
        ),2
    ) AS avg_discount_pct

FROM bigbasket_products
WHERE market_price > 0
GROUP BY brand_type;

-- P13
-- Stored procedure — dynamic pricing report by category + type

DELIMITER $$

CREATE PROCEDURE category_pricing_report(
    IN p_category VARCHAR(100)
)
BEGIN

    SELECT
        type,

        COUNT(*) AS total_products,

        ROUND(AVG(sale_price),2) AS avg_price,

        ROUND(
            AVG(
                ((market_price - sale_price)*100.0)
                / market_price
            ),2
        ) AS avg_discount_pct

    FROM bigbasket_products

    WHERE category = p_category

    GROUP BY type

    ORDER BY avg_discount_pct DESC;

END $$

DELIMITER ;

CALL category_pricing_report('Beverages');















DELIMITER $$

CREATE PROCEDURE get_count(
    OUT total_products INT
)
BEGIN

    SELECT COUNT(*)
    INTO total_products
    FROM bigbasket_products;

END $$

DELIMITER ;

select * from bigbasket_products;
delimiter $$
CREATE procedure category_pro()
begin 
select * from bigbasket_products
where category ='Beauty & Hygiene';
end $$
delimiter ;


drop procedure premet;
delimiter $$
create procedure premet( in categor varchar(50), in brand_p varchar(40))
begin
select * from bigbasket_products
where category =categor and brand=brand_p;
end $$
delimiter ;

call premet('Beauty & Hygiene','Sri Sri Ayurveda ');

select * from bigbasket_products;