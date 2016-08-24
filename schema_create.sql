USE books;  
GO

/*
Drop all objects for database recreate 
*/

/*
DROP TABLE dbo.Series_Defn;
GO

DROP TABLE dbo.Author;
GO

DROP TABLE dbo.author_stg;
GO

DROP TABLE dbo.Book;
GO

DROP TABLE dbo.Book_Author;
GO

DROP TABLE dbo.Book_Comment;
GO

DROP TABLE dbo.Book_Loan;
GO

DROP TABLE dbo.Book_Series;
GO

DROP TABLE dbo.book_stg;
GO

DROP TABLE dbo.Category_Defn;
GO

DROP TABLE dbo.nBook_stg;
GO

DROP TABLE dbo.Publisher_Defn;
GO

DROP TABLE dbo.Rating_Defn;
GO

DROP TABLE dbo.Status_Defn;
GO

DROP TABLE dbo.Sub_Category_Defn;
GO

*/

/* Truncate all tables for reload */

/*
TRUNCATE TABLE Author; 
GO
TRUNCATE TABLE Author_Stg; 
GO
TRUNCATE TABLE Book; 
GO
TRUNCATE TABLE Book_Author; 
GO
TRUNCATE TABLE Book_Comment; 
GO
TRUNCATE TABLE Book_Loan; 
GO
TRUNCATE TABLE Book_Series; 
GO
TRUNCATE TABLE Category_Defn; 
GO
TRUNCATE TABLE Format_Defn; 
GO
TRUNCATE TABLE Publisher_Defn; 
GO
TRUNCATE TABLE Rating_Defn; 
GO
TRUNCATE TABLE Series_Defn; 
GO
TRUNCATE TABLE Status_Defn; 
GO
TRUNCATE TABLE Sub_Category_Defn; 
GO

*/

-- Create dimension tables
CREATE TABLE Series_Defn      
(series_id   Integer      Not Null,
 series_name NVarChar(256) Not Null,
 CONSTRAINT Series_Defn_PK PRIMARY KEY CLUSTERED (series_id)
); 
GO

CREATE TABLE Publisher_Defn 
(publisher_id   Integer      Not Null,
 publisher_name VarChar(100) Not Null,
 CONSTRAINT Publisher_Defn_PK PRIMARY KEY CLUSTERED (publisher_id)
);
GO  

CREATE TABLE Format_Defn     
(format_id   Integer     Not Null,   
 format_name VarChar(50) Not Null,
 CONSTRAINT Type_Defn_PK PRIMARY KEY CLUSTERED (format_id)
);
GO  
 
 
CREATE TABLE Category_Defn 
(category_id   Integer     Not Null,   
 category_name VarChar(75) Not Null,
 CONSTRAINT Category_Defn_PK PRIMARY KEY CLUSTERED (category_id)
);
GO     
 
 
CREATE TABLE Sub_Category_Defn
(sub_category_id   Integer     Not Null,
 sub_category_name VarChar(75) Not Null,
 CONSTRAINT Sub_Category_Defn_PK PRIMARY KEY CLUSTERED (sub_category_id)
);
GO  
 
CREATE TABLE Status_Defn 
(status_id    Integer     Not Null,
 status_descr VarChar(10) Not Null,
 CONSTRAINT Status_Defn_PK PRIMARY KEY CLUSTERED (status_id)
);
GO  
 
CREATE TABLE Rating_Defn 
(rating_id   Integer     Not Null,
 rating_desc VarChar(10) Not Null,
 CONSTRAINT Rating_Defn_PK PRIMARY KEY CLUSTERED (rating_id)
);
GO  

-- Create fact tables
CREATE TABLE Book 
(book_id         Integer      Not Null,
 title           NVarChar(512) Not Null,
 publish_month   Char(2)      Not Null,
 publish_year    Char(4)      Not Null,
 isbn_asin       VarChar(20)  Not Null,
 format_id       Integer      Not Null,
 category_id     Integer      Not Null,
 sub_category_id Integer      Not Null,
 publisher_id    Integer      Not Null,
 status_id       Integer      Not Null,
 rating_id       Integer      Not Null,
 CONSTRAINT Book_PK PRIMARY KEY CLUSTERED (book_id)
);
GO    
 
CREATE TABLE Author 
(author_id  Integer      Not Null,
 first_name NVarChar(256) Not Null,
 last_name  NVarChar(256) Not Null,
 full_name  NVarChar(512) Not Null,
 CONSTRAINT Author_PK PRIMARY KEY CLUSTERED (author_id)
);
GO    
 
CREATE TABLE Book_Author 
(book_id   Integer   Not Null,
 author_id Integer   Not Null,
 CONSTRAINT Book_Author_PK PRIMARY KEY CLUSTERED (book_id, author_id)
);
GO  
 
CREATE TABLE Book_Series 
(book_id       Integer    Not Null,
 series_id     Integer    Not Null,
 series_number VarChar(10) Not Null,
 CONSTRAINT Book_Series_PK PRIMARY KEY CLUSTERED (book_id, series_id)
);
GO  
 
CREATE TABLE Book_Comment 
(book_id      Integer Not Null,
 comment_text Text    Not Null,
 CONSTRAINT Book_Comment_PK PRIMARY KEY CLUSTERED (book_id)
);
GO  
 
CREATE TABLE Book_Loan 
(book_id     Integer      Not Null,
 loan_date   Date         Not Null,
 return_date Date             Null,
 loan_name   VarChar(512) Not Null,
 CONSTRAINT Book_Loan_PK PRIMARY KEY CLUSTERED (book_id,loan_date)
);
GO  

/* Staging table for intitial data load */
CREATE TABLE Author_Stg
(author_id  Integer      Not Null,
 full_name  NVarChar(512) Not Null
);
GO  

/* Load defaults for dimensions */
INSERT INTO Category_Defn (category_id, category_name)
VALUES (0, 'None');
GO

INSERT INTO Sub_Category_Defn (sub_category_id, sub_category_name)
VALUES (0, 'None');
GO

INSERT INTO Format_Defn (format_id, format_name)
VALUES (0, 'Unknown');
GO

INSERT INTO Publisher_Defn (publisher_id, publisher_name)
VALUES (0, 'Unknown');
GO

INSERT INTO Rating_Defn (rating_id, rating_desc)
VALUES (0, 'None');
GO

INSERT INTO Status_Defn (status_id, status_descr)
VALUES (0, 'None');
GO

/* Add special Author of Unknown */
INSERT INTO Author (author_id, first_name, last_name, full_name)
VALUES (0, 'Unknown', ' ', 'Unknown');
GO