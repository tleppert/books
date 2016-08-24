SELECT * FROM Author

truncate table Author

select * from Publisher_Defn


select * from author_stg order by author_id

create table author_stg
(author_id integer not null,
 full_name nvarchar(512) not null)


CREATE TABLE Book_stg
(book_id         Integer      Not Null,
 title           VarChar(512) Not Null,
 publish_month   Char(2)      Not Null,
 publish_year    Char(4)      Not Null,
 isbn_asin       VarChar(20)  Not Null,
 category_id     Integer      Not Null,
 sub_category_id Integer      Not Null,
 publisher_id    Integer      Not Null,
 status_id       Integer      Not Null,
 rating_id       Integer      Not Null
);
GO    

BULK INSERT dbo.Book_stg
FROM 'C:\Users\Tom\MyProjects\Data\Book_20160731_0022.txt'
WITH ( FIELDTERMINATOR ='|', FIRSTROW = 1 )
GO


CREATE TABLE nBook_stg
(book_id         Integer      Not Null,
 title           NVarChar(512) Not Null,
 publish_month   Char(2)      Not Null,
 publish_year    Char(4)      Not Null,
 isbn_asin       VarChar(20)  Not Null,
 category_id     Integer      Not Null,
 sub_category_id Integer      Not Null,
 publisher_id    Integer      Not Null,
 status_id       Integer      Not Null,
 rating_id       Integer      Not Null
);
GO    

BULK INSERT dbo.nBook_stg
FROM 'C:\Users\Tom\MyProjects\Data\Book_20160731_0022.txt'
WITH ( FIELDTERMINATOR ='|', FIRSTROW = 1,CODEPAGE = 'ACP')
GO

select * from nbook_stg where book_id = 980;

delete from nbook_stg

select d.book_id, b.title
from   book_stg b
       inner join (select t.book_id, count(*) rcount
	               from   book_stg t
				   group by t.book_id
				   having count(*) > 1) d
	   on b.book_id = d.book_id
order by d.book_id

/*
book_id     title
----------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
978         Storm on the Horizon
978         Witchlight

980         The Seven Alters of Dvsarra
980         Breakdowns

1897        The General's Daughter
1897        1633

1898        Miracle at Midway
1898        Something to Read About

1899        Victory at Sea
1899        Bright of the Sky

1900        People of the Book
1900        If At First...

(12 row(s) affected)
*/

select * from author order by full_name, last_name;

select * 
from book_author ba
     inner join  nbook_stg b
	 on ba.book_id = b.book_id
	 inner join author a
	 on ba.author_id = a.author_id
where ba.author_id in (2145)
order by ba.author_id, ba.book_id;

select * 
from book_author ba
     inner join  book b
	 on ba.book_id = b.book_id
	 inner join author a
	 on ba.author_id = a.author_id
where ba.author_id in (501, 503)
order by ba.author_id, ba.book_id;


select * from book_stg where book_id = 980;


select * 
from book_author ba
     inner join  nbook_stg b
	 on ba.book_id = b.book_id
	 inner join author a
	 on ba.author_id = a.author_id
where ba.book_id in (2077)
order by ba.author_id, ba.book_id;


select  p.publisher_id,  p.publisher_name, count(b.book_id) bk_count
from   Publisher_Defn p
       inner join nbook_stg b
	   on p.publisher_id = b.publisher_id
group by p.publisher_name, p.publisher_id
order by p.publisher_name, p.publisher_id;

select *
from Publisher_Defn p
       inner join nbook_stg b
	   on p.publisher_id = b.publisher_id
where p.publisher_id in (458);

select *
from Publisher_Defn p
       inner join nbook_stg b
	   on p.publisher_id = b.publisher_id
	   inner join book_author ba
	   on b.book_id = ba.book_id
	   inner join author_stg a
	   on ba.author_id = a.author_id
where p.publisher_id in (458);

select *
from Publisher_Defn p
       inner join nbook_stg b
	   on p.publisher_id = b.publisher_id
	   inner join (select ba1.book_id,
                          STUFF ( (SELECT ';'+a2.full_name
	                               FROM book_author ba2
				                        inner join author_stg a2
					                    on ba2.author_id = a2.author_id
			                        where ba1.book_id = ba2.book_id
			                        order by a2.full_name
					                for xml path(''), type).value('.','varchar(max)'), 1,1,'') as authors
                   from book_author ba1
                   group by ba1.book_id) aut
       on b.book_id = aut.book_id
where p.publisher_id in (200, 258);


-- does not work
select ba1.book_id,
       STUFF( (SELECT ';'+a2.full_name
	           FROM author_stg a2
			   WHERE ba1.author_id = a2.author_id
			   ORDER BY  a2.full_name
			   FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
			   ,1,1,'') as authors
FROM Book_Author ba1
GROUP BY ba1.book_id;

select ba1.book_id,
       STUFF ( (SELECT ';'+a2.full_name
	            FROM book_author ba2
				     inner join author_stg a2
					 on ba2.author_id = a2.author_id
			     where ba1.book_id = ba2.book_id
			     order by a2.full_name
					 for xml path(''), type).value('.','varchar(max)'), 1,1,'') as authors
from book_author ba1
group by ba1.book_id



/*
SELECT p1.CategoryId,
       stuff( (SELECT ','+ProductName 
               FROM Northwind.dbo.Products p2
               WHERE p2.CategoryId = p1.CategoryId
               ORDER BY ProductName
               FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
            ,1,1,'')
       AS Products
      FROM Northwind.dbo.Products p1
      GROUP BY CategoryId ;
*/

select * from Series_Defn order by series_name

select *
from   Series_Defn sd
       inner join book_series bs
	   on sd.series_id = bs.series_id
	   inner join  nbook_stg b
	   on bs.book_id = b.book_id
where sd.series_id in (241)
order by sd.series_id, b.title


select *
from   Category_Defn c
order by c.category_name;

select *
from   Category_Defn c
       inner join  nbook_stg b
	   on c.category_id = b.category_id
where c.category_id in (13, 7)
order by c.category_id, b.book_id;


select *
from   Sub_Category_Defn c
order by c.sub_category_name;

select *
from   Sub_Category_Defn c
       inner join  nbook_stg b
	   on c.sub_category_id = b.sub_category_id
where c.sub_category_id in (121)
order by c.sub_category_id, b.book_id;


select * from Type_Defn
order by type_name


select * from format_defn

--drop table dbo.format_defn

select * from book where title like '%Secret%'
order by title

-- 2966	Enemy in the East: Hitler's Secret Plans to Invade the Soviet Union	02	    	9781780768298

select * from Publisher_Defn
where publisher_name like '%Portfolio%'
order by publisher_name

select * from author where last_name like 'Pri%'

select * from Series_Defn where series_name like '%Write%' order by series_name