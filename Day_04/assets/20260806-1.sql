-- Neue Datenbank erstellen
CREATE DATABASE testDB;

-- Fokus auf neue Datenbank legen
USE testDB;

-- Tabelle erstellen
CREATE TABLE author (
	id INT IDENTITY(1, 1),
	firstname NVARCHAR(40) NOT NULL,
	lastname NVARCHAR(40) NOT NULL,
	CONSTRAINT pk_author PRIMARY KEY (id)
);
GO

CREATE TABLE book (
	id INT IDENTITY PRIMARY KEY,
	title NVARCHAR(100) NOT NULL,
	isbn NCHAR(13) NOT NULL
);
GO

CREATE TABLE authorbook (
	author_id INT,
	book_id INT,
	CONSTRAINT pk_authorbook
		PRIMARY KEY (author_id, book_id),
	CONSTRAINT fk_authorbook_author
		FOREIGN KEY (author_id)
		REFERENCES author (id),
	CONSTRAINT fk_authorbook_book
		FOREIGN KEY (book_id)
		REFERENCES book (id)
);
GO
