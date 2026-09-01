USE WeitereBeispiele;

SELECT *
FROM SocialNetwork;

--	GROUPING mit "normalem" GROUP BY
SELECT NULL AS socialnetwork, NULL AS country, COUNT(*) AS anzahl
FROM SocialNetwork
UNION ALL
SELECT socialnetwork, NULL AS country, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY socialnetwork
UNION ALL
SELECT NULL AS socialnetwork, country, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY country
UNION ALL
SELECT socialnetwork, country, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY socialnetwork, country;

--	GROUPING mit GROUPING SETS
SELECT socialnetwork, country, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY 
	GROUPING SETS (
		(),
		socialnetwork,
		country,
		(socialnetwork, country)
	)
ORDER BY 
	GROUPING(socialnetwork),
	GROUPING(country);

--	GROUPING mit CUBE
--	Alle(!) möglichen Kombinationen aus den angegebenen Spalten
SELECT socialnetwork, country, firstname, lastname, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY 
	CUBE (socialnetwork, country, firstname, lastname)
ORDER BY 
	GROUPING(socialnetwork),
	GROUPING(country),
	GROUPING(firstname),
	GROUPING(lastname);

--	GROUPING mit ROLLUP
--	Spalten haben eine Hierarchie (links nach rechts)
SELECT socialnetwork, country, COUNT(*) AS anzahl
FROM SocialNetwork
GROUP BY
	ROLLUP (country, socialnetwork)
ORDER BY
	GROUPING(socialnetwork),
	GROUPING(country);
