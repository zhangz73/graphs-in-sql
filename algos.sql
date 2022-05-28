-- This file contains SQL procedures that find roots and commmunities in the graphs. For all stored procedures, it takes parameters `in_tname` and `out_tname`, where `in_tname` specifies the table name for graphs that contains columns `id` and `prev_id`, while `out_tname` is the output table containing columns `id` and `root_id` for root findings, or `id` and `label` for community detections.

-- Execute SQL From Text
delimiter //
drop procedure if exists execute_sql_from_text//
create procedure execute_sql_from_text(IN sql_text Varchar(1000))
begin
    set @sql_text1 = sql_text;
    prepare stmt1 from @sql_text1;
    execute stmt1;
    deallocate prepare stmt1;
end //
delimiter ;

-- Finding Roots of Graphs With Inherent Orderings
delimiter //
drop procedure if exists find_roots_ordered//
create procedure find_roots_ordered(
    IN in_tname Varchar(100),
    IN out_tname Varchar(100)
)
begin
    set @in_tname = in_tname;
    set @out_tname = out_tname;
    
    set @sql_text = concat('drop table if exists ', @out_tname);
    call execute_sql_from_text(@sql_text);
    
    set @sql_ret = concat('create table ', @out_tname, ' as select a.id, max(b.id) as root_id from ', @in_tname, ' a left join ', @in_tname, ' b on a.id >= b.id where b.prev_id is null group by a.id');
    call execute_sql_from_text(@sql_ret);
end //
delimiter ;

-- Finding Roots of General Directed Acyclic Graphs
delimiter //
drop procedure if exists find_roots_dag//
create procedure find_roots_dag(
    IN in_tname Varchar(100),
    IN out_tname Varchar(100)
)
begin
    set @in_tname = in_tname;
    set @out_tname = out_tname;

    drop table if exists tmp;
    set @sql_text1 = concat('create table tmp as select id, prev_id, case when prev_id is null then id else prev_id end as root_id, case when prev_id is null then 1 else 0 end as finished from ', @in_tname);
    call execute_sql_from_text(@sql_text1);

    set @finished = 0;
    while (@finished = 0) do
        drop table if exists curr;
        create table curr as
        select a.id, a.prev_id, case when a.finished = 1 then a.root_id else b.root_id end as root_id,
            case when a.finished = 1 or (a.finished = 0 and b.prev_id is null) then 1 else 0 end as finished
        from tmp a
        left join tmp b
        on a.root_id = b.id;
        
        drop table if exists tmp;
        create table tmp as select * from curr;
        
        set @finished = (select min(finished) from tmp);
    end while;

    set @sql_text2 = concat('drop table if exists ', @out_tname);
    call execute_sql_from_text(@sql_text2);

    set @sql_text3 = concat('create table ', @out_tname, ' as select id, root_id from tmp');
    call execute_sql_from_text(@sql_text3);
end //
delimiter ;

-- Community Detections
delimiter //
drop procedure if exists detect_communities//
create procedure detect_communities(
    IN in_tname Varchar(100),
    IN out_tname Varchar(100)
)
begin
    set @in_tname = in_tname;
    set @out_tname = out_tname;
    
    drop table if exists tmp;
    set @sql_setup = concat('create table tmp as select *, row_number() over() as rn from ', @in_tname);
    call execute_sql_from_text(@sql_setup);
    
    set @finished = 0;
    while (@finished = 0) do
        drop table if exists curr;
        create table curr as
        select z.id as id, z.prev_id as prev_id, z.rn as rn, y.rn2 as rn2
        from tmp z
        left join (
            select x.id as id, min(x.rn2) as rn2
            from (
                select c.id, case when d.rn is null or d.rn > c.rn2 then c.rn2 else d.rn end as rn2
                from (
                    select a.id as id,
                        case when b.rn is null or b.rn > a.rn then a.rn else b.rn end as rn2
                    from tmp a
                    left join tmp b
                    on a.prev_id = b.id
                ) c
                left join tmp d
                on c.id = d.prev_id
            ) x
            group by x.id
        ) y
        on z.id = y.id;
        
        drop table if exists tmp;
        create table tmp as
        select id, prev_id, rn2 as rn
        from curr;
        
        set @finished = (select min(case when rn = rn2 then 1 else 0 end) from curr);
    end while;
    
    drop table if exists ret;
    create table ret as
    select distinct id, dense_rank() over (order by rn) as label
    from tmp
    order by id;
    
    set @sql_text2 = concat('drop table if exists ', @out_tname);
    call execute_sql_from_text(@sql_text2);
    
    set @sql_out = concat('create table ', @out_tname, ' as select * from ret');
    call execute_sql_from_text(@sql_out);
end //
delimiter ;
