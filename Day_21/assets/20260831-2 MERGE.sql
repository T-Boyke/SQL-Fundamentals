USE WeitereBeispiele;

SELECT *
FROM ProductsLive;
SELECT *
FROM ProductsDW;

--	Synchronisierung der Daten mit MERGE
MERGE ProductsDW AS TGT
USING ProductsLive AS SRC
ON (TGT.ProductID = SRC.ProductID)
WHEN MATCHED AND (TGT.Price <> SRC.Price)
	THEN UPDATE SET TGT.Price = SRC.Price
WHEN NOT MATCHED BY TARGET
	THEN INSERT (ProductID, ProductName, Price) 
		VALUES (SRC.ProductID, SRC.ProductName, SRC.Price)
WHEN NOT MATCHED BY SOURCE
	THEN DELETE;


MERGE ProductsDW AS TGT
USING ProductsLive AS SRC
ON (TGT.ProductID = SRC.ProductID)
WHEN MATCHED AND (TGT.Price <> SRC.Price)
	-- DS aus Source in Target gefunden (aber anderer Preis)
	THEN UPDATE SET TGT.Price = SRC.Price
WHEN NOT MATCHED BY TARGET
	-- DS aus Source in Target nicht gefunden
	THEN INSERT (ProductID, ProductName, Price) 
		VALUES (SRC.ProductID, SRC.ProductName, SRC.Price)
WHEN NOT MATCHED BY SOURCE
	-- DS aus Target in Source nicht gefunden
	THEN UPDATE SET TGT.ProductName = CONCAT(TGT.ProductName, ' - invalid')
OUTPUT 
	$action,
	DELETED.ProductID,
	DELETED.ProductName,
	DELETED.Price,
	INSERTED.ProductName,
	INSERTED.Price;
