-- Data cleaning 
-- Layoffs from around the world: company, location, industry, total laid off, perc laid off, date, stage, country, funds

-- 1. REMOVING DUPLICATES
-- 2. STANDARDIZE DATA
-- 3 NULL AND BLANK VALUES
-- 4 REMOVE ANY UNECESSARY COLUMNS

CREATE TABLE layoffs_staging
LIKE layoffs;
SELECT *
FROM layoffs_staging;

-- insert the data from layoffs into layoffs_stagings
-- this is because the data is gonna be changed alot
INSERT layoffs_staging
SELECT *
FROM layoffs;

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,  industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging)

SELECT *
FROM duplicate_cte
WHERE row_num > 1; -- aftetr this rows with duplicates are displayed

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,  industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging)

DELETE 
FROM duplicate_cte
WHERE row_num > 1;

-- to remove duplicates, i created nothed table to be able to delete the values
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
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,  industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2;

DELETE 
FROM duplicate_cte
WHERE row_num > 1;

-- STANDARDIZE DATA

SELECT company, (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT distinct industry
FROM layoffs_staging2;
SELECT distinct location
FROM layoffs_staging2;
SELECT distinct country
FROM layoffs_staging2
WHERE country LIKE 'United States%';


-- Updating 'crypto currency' to just 'cryto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Formating date

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Update date to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- removing nulls and blank values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Populate blank values and null values
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
AND t2.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND T2.industry IS NOT NULL;

-- Set blanks to nulls
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Update 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND T2.industry IS NOT NULL;

-- removing rows because there are populated by NULL values
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- dropping rownum column 
ALTER TABLE layoffs_staging2
DROP column row_num;


