select * from book

select b.book_id, srbk.series_name, srbk.series_number, b.title, aut.authors, f.format_name,
       c.category_name, sc.sub_category_name, p.publisher_name, b.publish_month, b.publish_year,
	   b.isbn_asin, sd.status_descr, comment_text
from   book b
       inner join Category_Defn c
	   on b.category_id = c.category_id
	   inner join Sub_Category_Defn sc
	   on b.sub_category_id = sc.sub_category_id
	   inner join Status_Defn sd
	   on b.status_id = sd.status_id
	   inner join Publisher_Defn p
	   on b.publisher_id = p.publisher_id
	   inner join Format_Defn f
	   on b.format_id = f.format_id
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
	   left join (select ser.series_name, srb.series_id, srb.book_id, srb.series_number
	              from   Series_Defn ser
				         inner join Book_Series srb
						 on ser.series_id = srb.series_id) srbk
	    on b.book_id = srbk.book_id
		left join Book_Comment com
		on b.book_id = com.book_id
order by aut.authors, srbk.series_name, srbk.series_number, b.title


Select count(*) from book;

select 'TRUNCATE TABLE '+ name+ '; GO'
from sysobjects where type = 'U'
order by name;

SELECT * FROM book
WHERE publish_month != ' '
AND   publish_year = ' '
order by book_id

select * from format_defn

select * from book b where book_id not in (select book_id from Book_Author ba)

select * from Sub_Category_Defn

select * from Category_Defn order by category_id