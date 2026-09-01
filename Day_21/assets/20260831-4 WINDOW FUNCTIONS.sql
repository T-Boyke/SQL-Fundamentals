USE ProjektDB;

--	ranking window functions
SELECT *,
	ROW_NUMBER()
		OVER(ORDER BY gehalt) AS row_number,
	RANK()
		OVER(ORDER BY gehalt) AS rank,
	DENSE_RANK()
		OVER(ORDER BY gehalt) AS dense_rank,
	NTILE(4)
		OVER(ORDER BY gehalt) AS ntile
FROM Gehalt
ORDER BY gehalt;

SELECT *,
	RANK()
		OVER(PARTITION BY mit_id ORDER BY datum) AS rank_id,
	RANK()
		OVER(ORDER BY datum) AS rank
FROM Umsatz
ORDER BY datum

--	aggregate window functions
SELECT *,
	SUM(umsatz)
		OVER(PARTITION BY mit_id) AS mit_summe,
	MIN(Umsatz)
		OVER(PARTITION BY mit_id) AS mit_min,
	SUM(umsatz)
		OVER() AS summe
FROM Umsatz
ORDER BY mit_id, datum;

SELECT *,
	SUM(umsatz)
		OVER(PARTITION BY mit_id ORDER BY mit_id, datum, id
			 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS run_asc,
	SUM(umsatz)
		OVER(PARTITION BY mit_id ORDER BY mit_id, datum, id
			 ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS run_desc
FROM Umsatz
ORDER BY mit_id, datum, id;

SELECT *,
	SUM(umsatz) OVER(PARTITION BY mit_id) AS mit_summe,
	umsatz * 100 / SUM(umsatz) OVER(PARTITION BY mit_id) AS mit_prozent
FROM Umsatz
ORDER BY mit_id, datum;

--	offset window functions
SELECT id,
	LAG(id) OVER(ORDER BY id) AS prev,
	LEAD(id) OVER(ORDER BY id) AS next
FROM Mitarbeiter;

SELECT id, ort,
	FIRST_VALUE(id) OVER W1 AS first,
	LAST_VALUE(id) OVER(W1
						ROWS BETWEEN UNBOUNDED PRECEDING
							AND UNBOUNDED FOLLOWING) AS last
FROM Mitarbeiter
WINDOW W1 AS (PARTITION BY ort ORDER BY id)
ORDER BY ort, id;
