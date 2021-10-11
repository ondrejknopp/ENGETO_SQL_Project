CREATE TABLE semitable_ok_base AS 
	SELECT 
		DISTINCT cbd.date,
		cbd.country,
		tests.tests_performed,
		cbd.confirmed,
			CASE WHEN WEEKDAY(cbd.date) IN (5, 6) THEN 1 ELSE 0 END AS weekend_flag,
			CASE
			WHEN cbd.date BETWEEN '2019-12-21' AND '2020-03-20'  THEN 3
			WHEN cbd.date BETWEEN '2020-03-21' AND '2020-06-20'  THEN 0
			WHEN cbd.date BETWEEN '2020-06-21' AND '2020-09-22'  THEN 1
			WHEN cbd.date BETWEEN '2020-09-23' AND '2020-12-20'  THEN 2
			WHEN cbd.date BETWEEN '2020-12-21' AND '2021-03-20'  THEN 3
			WHEN cbd.date BETWEEN '2021-03-21' AND '2021-06-20'  THEN 0
			WHEN cbd.date BETWEEN '2021-06-21' AND '2021-09-22'  THEN 1
			WHEN cbd.date BETWEEN '2021-09-23' AND '2021-12-20'  THEN 2
			WHEN cbd.date BETWEEN '2021-12-21' AND '2022-03-20'  THEN 3
			ELSE 'chyba'
			END AS season_of_year -- kde 0 = jaro, 3 = zima
 -- varianta kratöÌ a univerz·lÏnjöÌ, ale mÈnÏ p¯esn· by mohla b˝t:
 -- CASE
    --  when month(cbd.date) in (3, 4, 5) then 0
    --  when month(cbd.date) in (6, 7, 8) then 1
    --  when month(cbd.date) in (9, 10, 11) then 2
    --  when month(cbd.date) in (12, 1, 2) then 3
-- end) as season
	FROM covid19_basic_differences AS cbd 
	LEFT JOIN v_ok_countries c 
		ON cbd.country = c.country
	LEFT JOIN v_ok_economies AS eco
		ON cbd.country = eco.country
	LEFT JOIN covid19_tests AS tests
		ON cbd.country = tests.country
		AND cbd.date = tests.date
	ORDER BY date
;

CREATE OR REPLACE VIEW v_ok_countries AS
	SELECT
		c.country,
		c.population_density AS hustota_zalidneni,
		c.population AS populace,
		c.median_age_2018 AS medi·n_vÏku_2018
	FROM countries AS c
;

CREATE OR REPLACE VIEW v_ok_economies AS
	SELECT
		DISTINCT
		eco.country,
		eco.GDP/eco.population AS HDP_na_obyvatele,
		eco.mortaliy_under5 AS detska_umrtnost,
		eco.gini AS Gini_coef
	FROM economies AS eco
	WHERE YEAR = 2018
;

CREATE TABLE semitable_okv3 AS 
	SELECT 
		DISTINCT
		ok_bdw.country,
		ok_bdw.date,
		ok_bdw.tests_performed,
		ok_bdw.confirmed,
		ok_bdw.weekend_flag,
		ok_bdw.season_of_year,
		led.life_expectancy_diff AS 'rozdil_doziti_1965/2015'
	FROM ok_basic_data_view AS ok_bdw
	LEFT JOIN life_expectyncy_diff led 
		ON ok_bdw.country = led.country 
	ORDER BY date ASC
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



-- ********************   PO»ASÕ STUFF    ****************** --

CREATE OR REPLACE view v_weather_n·razy AS
	SELECT
		DATE(`date`) AS datum,
		city,
		MAX(gust) AS vÌtr_n·razy
	FROM weather w
	WHERE TIME(`time`) BETWEEN '00:00' AND '21:00' AND city IS NOT NULL  
	GROUP BY DATE(`date`), city;


CREATE OR REPLACE view v_weather_AVGTEMP AS
	SELECT
		DATE(`date`) AS datum,
		city,
		AVG(REGEXP_SUBSTR(temp,'[0-9]+')) AS pr˘mÏrn·_dennÌ_teplota
	FROM weather w
	WHERE TIME(`time`) BETWEEN '06:00' AND '18:00' AND city IS NOT NULL  
	GROUP BY DATE(`date`), city
;

CREATE OR REPLACE view v_weather_srazky AS
	SELECT
		DATE(`date`) AS datum,
		city,
		SUM(CASE WHEN rain != "0.0 mm" THEN 3 ELSE 0 END) AS hodin_deste
		-- SUM(destivy_usek) AS pocet_hodin_deste_denne
	FROM weather w
	WHERE TIME(`time`) BETWEEN '00:00' AND '21:00' AND city IS NOT NULL  
	GROUP BY DATE(`date`), city
;

CREATE OR REPLACE VIEW v_ok_weather_report AS
	SELECT
		sm.country, 
		wn.datum,
		wn.city AS mÏsto,
		wn.vÌtr_n·razy,
		wa.pr˘mÏrn·_dennÌ_teplota,
		ws.hodin_deste
	FROM v_weather_n·razy wn
	LEFT JOIN v_weather_avgtemp wa 
		ON wn.datum = wa.datum
		AND wn.city = wa.city
	LEFT JOIN v_weather_srazky ws 
		ON wn.datum = ws.datum
		AND wn.city = ws.city
	LEFT JOIN v_stat_mesto sm 
		ON wn.city = sm.capital_city 
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
CREATE OR REPLACE VIEW v_crist_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS podÌl_k¯esùanstvÌ_v_prc
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Christianity'
;

CREATE OR REPLACE VIEW v_islam_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS podÌl_Isl·mu_v_prc
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Islam'
;


CREATE OR REPLACE VIEW v_hinduism_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS podÌl_Hinduismu_v_prc
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Hinduism'
;

CREATE OR REPLACE VIEW v_buddhism_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS podÌl_Buddhismu_v_prc
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Buddhism'
;

CREATE OR REPLACE VIEW v_judaism_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS podÌl_Judaismu_v_prc
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Judaism'
;

CREATE OR REPLACE VIEW v_Folk_share AS 
	SELECT
		country,
		(pocet_vericich/celkova_populace)*100 AS podÌl_Folk_rel_v_prc
	FROM v_religion_stat vrs
	WHERE nabozenstvi = 'Folk Religions'

CREATE TABLE ok_nabozenska_statistika AS
	SELECT
		vcs.country,
		vcs.podÌl_k¯esùanstvÌ_v_prc,
		vis.podÌl_Isl·mu_v_prc,
		vbs.podÌl_Buddhismu_v_prc,
		vhs.podÌl_Hinduismu_v_prc,
		vjs.podÌl_Judaismu_v_prc,
		vfs.podÌl_Folk_rel_v_prc
	FROM v_crist_share vcs 
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

CREATE TABLE FINAL_OVERVIEW AS
	SELECT
	sob.`date`,
	sob.country,
	sob.tests_performed,
	sob.confirmed,
	sob.weekend_flag,
	sob.season_of_year,
	voc.hustota_zalidneni,
	voc.populace,
	voc.medi·n_vÏku_2018,
	voe.HDP_na_obyvatele,
	voe.detska_umrtnost,
	voe.Gini_coef,
	ons.podÌl_k¯esùanstvÌ_v_prc,
	ons.podÌl_Isl·mu_v_prc,
	ons.podÌl_Buddhismu_v_prc,
	ons.podÌl_Hinduismu_v_prc,
	ons.podÌl_Judaismu_v_prc ,
	vowr.vÌtr_n·razy,
	vowr.pr˘mÏrn·_dennÌ_teplota,
	vowr.hodin_deste 
	FROM semitable_okv3 sob
	LEFT JOIN v_ok_countries voc 
		ON sob.country = voc.country 
	LEFT JOIN v_ok_economies voe 
		ON sob.country = voe.country 
	LEFT JOIN ok_nabozenska_statistika ons 
		ON sob.country = ons.country 
	LEFT JOIN v_ok_weather_report vowr 
		ON sob.country = vowr.country
		;


