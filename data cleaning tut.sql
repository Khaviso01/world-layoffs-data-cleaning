SELECT company, location, total_laid_off AS total
FROM layoffs
WHERE total_laid_off > 300
order by company;

-- CREATE A NEW TABLE
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;
-- REMOVING DUPLICATES
SELECT *
FROM layoffs_staging;

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, stage, percentage_laid_off, country, `date`, stage) as row_num -- devides into groups of rows
FROM layoffs_staging) 
SELECT *
from duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
from layoffs_staging2;

-- insert CTE information
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, stage, percentage_laid_off, country, `date`, stage) as row_num -- devides into groups of rows
FROM layoffs_staging;

SELECT *
from layoffs_staging2
WHERE row_num > 1;

-- Officially removing the duplicates
DELETE 
from layoffs_staging2
WHERE row_num > 1;
SELECT *
from layoffs_staging2;

SELECT industry, location
FROM layoffs
WHERE industry LIKE 'Marketing';

-- standardizing data: finding issues in data and fixing it

SELECT company, TRIM(company) -- takes wide space off the ends
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2 
SET industry = 'Crypto'
where industry LIKE 'Crypto&';

select DISTINCT country
from layoffs_staging2
WHERE country LIKE 'United States&';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States&';

SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

-- Dealing with nulls
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
-- populating industry for the first one
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- set the other blanks to null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

DELETE -- THIS IS THE DATA I CAN'T TRUST BECAUSE OF THE NULLS
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
-- FINALLY to check final data where i've standardized, removed null values, and removed unneccesay colums and rows
SELECT * 
FROM layoffs_staging2;
