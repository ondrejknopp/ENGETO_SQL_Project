CREATE TABLE semitable_ok_base AS 
	SELECT 
		DISTINCT 
		cbd.date,
		cbd.country,
		tests.tests_performed,
		cbd.confirmed,
		CASE WHEN WEEKDAY(cbd.date) IN (5, 6) THEN 1 ELSE 0 END AS weekend_flag,
		CASE
 		WHEN MONTH(cbd.date) = 3 AND dayofmonth(cbd.date) >= 21 THEN 0
    	WHEN MONTH(cbd.date) in (4, 5) THEN 0
    	WHEN MONTH(cbd.date) = 6 AND dayofmonth(cbd.date) < 21 THEN 0
    	WHEN MONTH(cbd.date) = 6 AND dayofmonth(cbd.date) >= 21 THEN 1
    	WHEN MONTH(cbd.date) in (7, 8) THEN 1
    	WHEN MONTH(cbd.date) = 9 AND dayofmonth(cbd.date) < 23 THEN 1
    	WHEN MONTH(cbd.date) = 9 AND dayofmonth(cbd.date) >= 23 THEN 2
    	WHEN MONTH(cbd.date) in (10, 11) then 2
    	WHEN MONTH(cbd.date) = 12 AND dayofmonth(cbd.date) < 21 THEN 2
    	WHEN MONTH(cbd.date) = 12 AND dayofmonth(cbd.date) >= 21 THEN 3
    	WHEN MONTH(cbd.date) in (1, 2) then 3
    	WHEN MONTH(cbd.date) = 3 AND dayofmonth(cbd.date) < 21 THEN 3
    	END AS season_of_year,
	led.life_expectancy_diff AS 'rozdil_doziti_1965/2015'
	FROM covid19_basic_differences AS cbd 
	LEFT JOIN covid19_tests AS tests
		ON cbd.country = tests.country
		AND cbd.date = tests.date
	LEFT JOIN life_expectyncy_diff led 
		ON cbd.country = led.country
	ORDER BY date
;


CREATE OR REPLACE VIEW v_ok_countries AS
	SELECT
		DISTINCT 
		c.country,
		c.population_density,
		c.population,
		c.median_age_2018
	FROM countries AS c
;

CREATE OR REPLACE VIEW v_ok_economies AS
	SELECT
		DISTINCT
		eco.country,
		eco.GDP/eco.population AS GDP_per_capita,
		eco.mortaliy_under5 AS child_mortality,
		eco.gini AS Gini_coef
	FROM economies AS eco
	WHERE YEAR = 2018
;



CREATE OR REPLACE VIEW v_stat_mesto AS
	SELECT
		DISTINCT 
		country,
		CASE 
		WHEN capital_city = 'Wien' THEN 'Vienna'
		WHEN capital_city = 'Bruxelles [Brussel]' THEN 'Brussels'
		WHEN capital_city = 'Praha' THEN 'Prague'
		WHEN capital_city = 'Helsinki [Helsingfors]' THEN 'Helsinki'
		WHEN capital_city = 'Athenai' THEN 'Athens'
		WHEN capital_city = 'Roma' THEN 'Rome'
		WHEN capital_city = 'Luxembourg [Luxemburg/L' THEN 'Luxembourg'
		WHEN capital_city = 'Warszawa' THEN 'Warsaw'
		WHEN capital_city = 'Bucuresti' THEN 'Bucharest'
		WHEN capital_city = 'Kyiv' THEN 'Kiev'
		ELSE capital_city END AS capital_city
	FROM countries c
;



-- ********************   WEATHER STUFF    ****************** --

CREATE OR REPLACE view v_weather_gust AS
	SELECT
		DATE(`date`) AS datum,
		city,
		MAX(gust) AS vitr_narazy
	FROM weather w
	WHERE TIME(`time`) BETWEEN '00:00' AND '21:00' AND city IS NOT NULL  
	GROUP BY DATE(`date`), city;


CREATE OR REPLACE view v_weather_AVGTEMP AS
	SELECT
		DATE(`date`) AS datum,
		city,
		AVG(REGEXP_SUBSTR(temp,'[0-9]+')) AS average_daily_temperature
	FROM weather w
	WHERE TIME(`time`) BETWEEN '06:00' AND '18:00' AND city IS NOT NULL  
	GROUP BY DATE(`date`), city
;

CREATE OR REPLACE view v_weather_srazky AS
	SELECT
		DATE(`date`) AS datum,
		city,
		SUM(CASE WHEN rain != "0.0 mm" THEN 3 ELSE 0 END) AS hodin_deste
	FROM weather w
	WHERE TIME(`time`) BETWEEN '00:00' AND '21:00' AND city IS NOT NULL  
	GROUP BY DATE(`date`), city
;

CREATE OR REPLACE VIEW v_ok_weather_report AS
	SELECT
		sm.country, 
		wg.datum,
		wg.city,
		wg.vitr_narazy,
		wa.average_daily_temperature,
		ws.hodin_deste AS hours_raining
	FROM v_weather_gust wg
	LEFT JOIN v_weather_avgtemp wa 
		ON wg.datum = wa.datum
		AND wg.city = wa.city
	LEFT JOIN v_weather_srazky ws 
		ON wg.datum = ws.datum
		AND wg.city = ws.city
	LEFT JOIN v_stat_mesto sm 
		ON wg.city = sm.capital_city 
;



 -- **************** RELIGION STUFF ************** -- 

CREATE OR REPLACE VIEW v_religion_stat AS
	SELECT 
		r.country,
		c.population AS celkova_populace,
		r.religion AS nabozenstvi,
		r.population AS pocet_vericich		
	FROM religions r 
	LEFT JOIN countries c
		ON r.country = c.country
	WHERE r.`year` = 2020;

-- podil Krestanstvi 
CREATE OR REPLACE VIEW v_christ_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS Christianity_percentage
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Christianity'
;

CREATE OR REPLACE VIEW v_islam_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS Islam_percentage
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Islam'
;


CREATE OR REPLACE VIEW v_hinduism_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS Hinduism_percentage
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Hinduism'
;

CREATE OR REPLACE VIEW v_buddhism_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS Buddhism_percentage
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Buddhism'
;

CREATE OR REPLACE VIEW v_judaism_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS Judaism_percentage
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Judaism'
;

CREATE OR REPLACE VIEW v_Folk_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS Folk_rel_percentage
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Folk Religions'

CREATE TABLE ok_religion_statistics AS
	SELECT
		vcs.country,
		vcs.Christianity_percentage,
		vis.Islam_percentage,
		vbs.Buddhism_percentage,
		vhs.Hinduism_percentage,
		vjs.Judaism_percentage,
		vfs.Folk_rel_percentage
	FROM v_christ_share vcs 
	LEFT JOIN v_islam_share vis 
		ON vcs.country = vis.country 
	LEFT JOIN v_buddhism_share vbs 
		ON vcs.country = vbs.country
	LEFT JOIN v_hinduism_share vhs 
		ON vcs.country = vhs.country 
	LEFT JOIN v_judaism_share vjs 
		ON vcs.country = vjs.country 
	LEFT JOIN v_folk_share vfs 
		ON vcs.country = vfs.country
	;


-- *** BRINGING ALL TOGETHER *** -- 

CREATE TABLE FINAL_OVERVIEW_KNOPP AS
	SELECT
	DISTINCT 
	sob.`date`,
	sob.country,
	sob.tests_performed,
	sob.confirmed,
	sob.weekend_flag,
	sob.season_of_year,
	voc.population_density,
	voc.population,
	voc.median_age_2018,
	voe.GDP_per_capita,
	voe.child_mortality,
	voe.Gini_coef,
	ors.Christianity_percentage,
	ors.Islam_percentage,
	ors.Buddhism_percentage,
	ors.Hinduism_percentage,
	ors.Judaism_percentage,
	vowr.vitr_narazy,
	vowr.average_daily_temperature,
	vowr.hours_raining 
	FROM semitable_ok_base sob
	LEFT JOIN v_ok_countries voc 
		ON sob.country = voc.country 
	LEFT JOIN v_ok_economies voe 
		ON sob.country = voe.country 
	LEFT JOIN ok_religion_statistics ors 
		ON sob.country = ors.country 
	LEFT JOIN v_ok_weather_report vowr 
		ON sob.country = vowr.country
		AND sob.`date` = vowr.datum 
		;

