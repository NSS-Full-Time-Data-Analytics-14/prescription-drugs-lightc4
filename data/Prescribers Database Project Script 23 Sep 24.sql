--Lightner 23 Sep 24
--Prescribers Database Project
## Prescribers Database

For this exericse, you'll be working with a database derived from the 
[Medicare Part D Prescriber Public Use File]
(https://www.hhs.gov/guidance/document/medicare-provider-utilization-and-payment-data-part-d-prescriber-0)
More information about the data is contained in the Methodology PDF file. 
See also the included entity-relationship diagram.

## ATTENTION!!!!
There is duplication in the drugs table.  
Run 'SELECT COUNT(drug_name) FROM drug' then 'SELECT COUNT (DISTINCT drug_name) FROM drug'.  
Notice the difference?  
You can investigate further and then be sure to consider the duplication when joining to the drug table.

SELECT *
FROM drug;
--There are 120 drug duplications based on the query below:
SELECT COUNT(drug_name), drug_name
FROM drug 
GROUP BY drug_name
HAVING COUNT(drug_name) > 1;
------------------------------------------------
--The query below returns 3425 drugs
SELECT COUNT(drug_name) 
FROM drug;

--The query below returns 3253 drugs
SELECT COUNT (DISTINCT drug_name) 
FROM drug;

1a. Which prescriber had the highest total number of claims (totaled over all drugs)? 
Report the npi and the total number of claims.

SELECT *
FROM prescriber; 

SELECT *
FROM prescription; 
----------------------------
--1a.This is the correct response immediately below.
SELECT npi,
		SUM(total_claim_count)
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC;


--Tables joined
SELECT *
FROM prescriber
 INNER JOIN prescription
 USING(npi)
	
SELECT 
	SUM(prescription.total_claim_count_ge65), 
	prescription.drug_name
FROM prescription
	INNER JOIN prescriber
	USING(npi)
GROUP BY prescription.drug_name;


1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,
specialty_description, and the total number of claims.
--Did an INNER JOIN and it did not work with the query
SELECT COUNT(prescription.total_claim_count),
		prescription.npi
FROM prescription
	FULL JOIN prescriber
	USING(npi)
	GROUP BY prescription.npi;

SELECT COUNT(prescription.total_claim_count),
		prescriber.nppes_provider_last_org_name,
		prescriber.nppes_provider_first_name,
		prescriber.specialty_description,
		prescription.npi
FROM prescription
	INNER JOIN prescriber
	USING(npi)
	GROUP BY prescriber.nppes_provider_last_org_name, 
			 prescriber.nppes_provider_first_name,
			 prescriber.specialty_description,
			 prescription.npi;


2a. Which specialty had the most total number of claims (totaled over all drugs)?
--prescriber.specialty_description  prescription.total_30_day_fill_count
-------------------------------------------------------------
--2a. Family Practice is the specialty with the most total number of claims 9152347

SELECT SUM(prescription.total_claim_count),
		prescriber.specialty_description
FROM prescription
INNER JOIN prescriber
USING(npi)
GROUP BY prescriber.specialty_description 
ORDER BY SUM(prescription.total_claim_count) DESC;
-------------------------------------------------------

2b. Which specialty had the most total number of claims for opioids?
--How do I know which drug is an opioid?
SELECT *
FROM drug
--OK it is a "Y"  in the drug.opioid_drug_flag field

SELECT *
FROM drug
WHERE opioid_drug_flag = 'Y'
--There are 91 opioid_drug_flag 'Y'
---------------------------------------------------
--JOIN prescription.total_claim_count 

SELECT prescription.total_claim_count,
		drug.opioid_drug_flag
FROM prescription
	INNER JOIN drug
	USING(drug_name)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescription.total_claim_count, drug.opioid_drug_flag
ORDER BY prescription.total_claim_count DESC

--Now JOIN prescriber.specialty_description

SELECT prescription.total_claim_count,
		drug.opioid_drug_flag,
		prescriber.specialty_description
FROM prescription
	INNER JOIN drug
	USING(drug_name)
	INNER JOIN prescriber
	USING(npi)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescription.total_claim_count, drug.opioid_drug_flag, prescriber.specialty_description
ORDER BY prescription.total_claim_count DESC

-- SELECT 
-- 	SUM(prescription.total_claim_count_ge65), 
-- 	prescription.drug_name
-- FROM prescription
-- 	INNER JOIN prescriber
-- 	USING(npi)
-- GROUP BY prescription.drug_name;

2c. **Challenge Question:** Are there any specialties that appear in the prescriber table 
that have no associated prescriptions in the prescription table?

2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!*
For each specialty, report the percentage of total claims by that specialty which are for opioids. 
Which specialties have a high percentage of opioids?

3a. Which drug (generic_name) had the highest total drug cost?
--I am using drug.generic_name and prescription.total_drug_cost
--JOIN prescription ON drug USING(drug_name) but what can I do with prescription

SELECT DISTINCT drug_name 
FROM prescription

SELECT DISTINCT drug_name, total_drug_cost
FROM prescription

SELECT drug_name, 
		SUM(total_drug_cost)
FROM prescription
GROUP BY drug_name
----------------------------------------
--Now JOIN drug_name
3a. Which drug (generic_name) had the highest total drug cost?
--Lyrica (Pregabalin), with $78645939 total drug cost?

SELECT prescription.drug_name, 
		drug.generic_name,
		SUM(prescription.total_drug_cost)
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY prescription.drug_name, drug.generic_name
ORDER BY SUM(prescription.total_drug_cost) DESC

------------------------------------------------------------------
3b. Which drug (generic_name) has the hightest total cost per day?
**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
--total_day_supply / total_drug_cost  AS cost_per_day
----I am using drug.generic_name and prescription.total_drug_cost
--JOIN prescription ON drug USING(drug_name) but what can I do with prescription
--One table data

SELECT drug_name, total_day_supply, total_drug_cost
FROM prescription

SELECT drug_name,  total_drug_cost
FROM prescription
ORDER BY total_drug_cost DESC
LIMIT 5
-------------------------------------------------Odd output above-no time to explore

SELECT drug_name,  ROUND((total_drug_cost/total_day_supply),2) AS daily_med_cost
FROM prescription
ORDER BY daily_med_cost DESC;
--From the query above, Gammagard Liquid has the highest daily cost at $7141.11 daily
--What is the generic name of Gammagard Liquid?

SELECT prescription.drug_name,
		drug.generic_name,
		ROUND((prescription.total_drug_cost/prescription.total_day_supply), 2) 
		AS daily_med_cost
FROM prescription
INNER JOIN drug
USING(drug_name)
ORDER BY daily_med_cost DESC
LIMIT 5;
--From the query above, Immun Glob G (IGG)/GLY/IGA OV50
--Gammagard Liquid has the highest daily cost at $7141.11 daily
____________________________________________________________________________________________

4a. For each drug in the drug table, return the drug name and then a
column named 'drug_type'which says 'opioid' for drugs which have opioid_drug_flag = 'Y', 
says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y',
and says 'neither' for all other drugs. 
**Hint:** You may want to use a CASE expression for this. 
See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT *
FROM drug

SELECT drug_name, generic_name, 
		CASE WHEN opioid_drug_flag = 'Y'     THEN 'opioid' 
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'neither' 
		END AS drug_type
FROM drug
--For the query above, remove 'generic_name' before submission.
				  
4b. Building off of the query you wrote for part a, 
determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
Hint: Format the total costs as MONEY for easier comparision.
--total_drug_cost is in prescription so I have to JOIN drug and prescription tables
--But now I want to try to filter the original query to remove 'neither' records
--Call them 'NULL'?

SELECT drug_name, generic_name, 
		CASE WHEN opioid_drug_flag = 'Y'     THEN 'opioid' 
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE NULL 
		END AS drug_type
FROM drug
WHERE (opioid_drug_flag = 'Y' OR antibiotic_drug_flag = 'Y')
--I guess I could have kept the original query
--------------------------------------Now try to JOIN drug and prescription tables
-- Stuck at adding field 'prescription.total_drug_cost,' at the very top before DISTINCT
-- Maybe do another SELECT?

SELECT DISTINCT drug.drug_name,  
		CASE WHEN drug.opioid_drug_flag = 'Y'     THEN 'opioid' 
			 WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'neither' 
		END AS drug_type
FROM drug
CASE WHEN opioid_drug_flag = 'Y'     THEN 'opioid' 
ELSE NULL 
		END AS drug_type
INNER JOIN prescription
USING(drug_name)
WHERE (drug.opioid_drug_flag = 'Y' OR drug.antibiotic_drug_flag = 'Y')
____________________________________________________________________
--working below--okay--add the new field AFTER the CASE statement
--CHRIS: showed me how to do a CTE for 4b

WITH drug_type_cost AS 
(SELECT DISTINCT drug.drug_name,  
		CASE WHEN drug.opioid_drug_flag = 'Y'     THEN 'opioid' 
			 WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'neither' 
		END AS drug_type,
		prescription.total_drug_cost
FROM drug
INNER JOIN prescription
USING(drug_name)
WHERE (drug.opioid_drug_flag = 'Y' OR drug.antibiotic_drug_flag = 'Y')	)

SELECT SUM(total_drug_cost),
drug_type
FROM drug_type_cost
GROUP BY drug_type


5a. How many CBSAs are in Tennessee? **Warning:** 
The cbsa table contains information for all states, not just Tennessee.

SELECT *
FROM cbsa

SELECT *
FROM cbsa
WHERE cbsaname LIKE '%TN%'

SELECT DISTINCT cbsa
FROM cbsa
WHERE cbsaname LIKE '%TN%'
______________Correct query below (I think)
SELECT DISTINCT cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%'

5b. Which cbsa has the largest combined population? 
Which has the smallest? Report the CBSA name and total population.
-----------------------------------------Looks like the JOIN works
SELECT *
FROM population
ORDER BY population 

SELECT fipscounty, population
FROM population
ORDER BY population 
----------------------------------------------------------
SELECT 		    cbsa.cbsa, 
				cbsa.cbsaname,
				cbsa.fipscounty,
				population.population
FROM cbsa
INNER JOIN population
USING(fipscounty)
WHERE cbsaname LIKE '%TN%' 




5c. What is the largest (in terms of population) county which is not included in a CBSA? 
Report the county name and population.





6a. Find all rows in the prescription table where total_claims is at least 3000. 
Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >=3000

6b. For each instance that you found in part a, 
add a column that indicates whether the drug is an opioid.

SELECT drug_name, total_claim_count,
CASE WHEN opioid_drug_flag = 'Y'     THEN 'opioid' 
ELSE NULL 
		END AS drug_type
FROM prescription
INNER JOIN drug
USING(drug_name)

WHERE total_claim_count >=3000

6c. Add another column to you answer from the previous part 
which gives the prescriber first and last name associated with each row.

SELECT prescription.drug_name, prescription.total_claim_count,
		prescriber.nppes_provider_last_org_name ||' '||
		prescriber.nppes_provider_first_name AS provider_name,
CASE WHEN opioid_drug_flag = 'Y'     THEN 'opioid' 
ELSE NULL 
		END AS drug_type
FROM prescription
INNER JOIN drug
USING(drug_name)

INNER JOIN prescriber
USING(npi)
WHERE total_claim_count >=3000


7. The goal of this exercise is to generate a full list of all 
pain management specialists in Nashville and the number of claims they had for each opioid. 
**Hint:** The results from all 3 parts will have 637 rows.

a. First, create a list of all npi/drug_name combinations 
for pain management specialists 
(specialty_description = 'Pain Management) 
in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
where the drug is an opioid (opiod_drug_flag = 'Y'). 
**Warning:** Double-check your query before running it. 
You will only need to use the prescriber and drug tables 
since you don't need the claims numbers yet.

SELECT *
FROM prescriber

SELECT *
FROM drug

SELECT npi, specialty_description, nppes_provider_city
FROM prescriber

WHERE 
specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE'

SELECT npi
FROM prescription
subquery or cross join

SELECT prescriber.npi, prescriber.specialty_description,prescriber.nppes_provider_city
FROM prescriber 
CROSS JOIN drug 
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y'

--CORRECT QUERY BELOW------------------------------------------------------------------
SELECT prescriber.npi, drug.drug_name
FROM prescriber 
CROSS JOIN drug 
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y'


b. Next, report the number of claims per drug per prescriber. 
Be sure to include all combinations, whether or not the prescriber had any claims. 
You should report the npi, the drug name, and the number of claims (total_claim_count).
--CORRECT QUERY BELOW------------------------------------------------------------------
WITH npi_drug_combo AS 
	(SELECT prescriber.npi, drug.drug_name
	FROM prescriber 
	CROSS JOIN drug 
	WHERE prescriber.specialty_description = 'Pain Management'
	AND prescriber.nppes_provider_city = 'NASHVILLE'
	AND drug.opioid_drug_flag = 'Y')

SELECT npi, drug_name, total_claim_count
FROM npi_drug_combo

LEFT JOIN prescription
USING(drug_name, npi) 

--------------------------------------------------------------------------------------------
SELECT *
FROM prescription

SELECT DISTINCT drug_name, total_claim_count, npi
FROM prescription
ORDER BY total_claim_count DESC

SELECT *
FROM prescriber

SELECT DISTINCT prescriber.nppes_provider_last_org_name ||' '||
		prescriber.nppes_provider_first_name AS provider_name 
FROM prescriber
______________________________________________________________

SELECT DISTINCT prescription.drug_name, 
				prescription.total_claim_count, 
				prescription.npi
FROM prescription

FULL JOIN prescriber
USING(npi)
ORDER BY prescription.total_claim_count DESC
------------------------The query above gives me null values and I still need provider name

SELECT DISTINCT prescription.drug_name, 
				prescription.total_claim_count, 
				prescription.npi
FROM prescription

CROSS JOIN prescriber
ORDER BY prescription.total_claim_count DESC



b. Next, report the number of claims per drug per prescriber. 
Be sure to include all combinations, whether or not the prescriber had any claims. 
Report the npi, the drug name, and the number of claims (total_claim_count).

SELECT DISTINCT prescription.drug_name, 
				prescription.total_claim_count, 
				prescription.npi,
				prescriber.nppes_provider_last_org_name
FROM prescription

CROSS JOIN prescriber


ORDER BY prescription.total_claim_count DESC


c. Finally, if you have not done so already, 
fill in any missing values for total_claim_count with 0. 
Hint - Google the COALESCE function.

WITH npi_drug_combo AS 
	(SELECT prescriber.npi, drug.drug_name
	FROM prescriber 
	CROSS JOIN drug 
	WHERE prescriber.specialty_description = 'Pain Management'
	AND prescriber.nppes_provider_city = 'NASHVILLE'
	AND drug.opioid_drug_flag = 'Y')

SELECT npi, drug_name, COALESCE(total_claim_count, 0) AS total_claim_count_no_nulls
FROM npi_drug_combo

LEFT JOIN prescription
USING(drug_name, npi) 

