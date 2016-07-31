USE books;  
GO

-- Create dimension tables
CREATE TABLE Series_Defn      
(series_id   Integer      Not Null,
 series_name VarChar(256) Not Null,
 CONSTRAINT Series_Defn_PK PRIMARY KEY CLUSTERED (series_id)
); 
GO

CREATE TABLE Publisher_Defn 
(publisher_id   Integer      Not Null,
 publisher_name VarChar(100) Not Null,
 CONSTRAINT Publisher_Defn_PK PRIMARY KEY CLUSTERED (publisher_id)
);
GO  

CREATE TABLE Type_Defn     
(type_id   Integer     Not Null,   
 type_name VarChar(50) Not Null,
 CONSTRAINT Type_Defn_PK PRIMARY KEY CLUSTERED (type_id)
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
 title           VarChar(512) Not Null,
 publish_month   Char(2)      Not Null,
 publish_year    Char(4)      Not Null,
 isbn_asin       VarChar(20)  Not Null,
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
 first_name VarChar(256) Not Null,
 last_name  VarChar(256) Not Null,
 full_name  VarChar(512) Not Null,
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
 series_number VarChar(4) Not Null,
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
