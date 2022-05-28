-- Create And Setup Database
create database graphs_in_sql;
use graphs_in_sql;

-- Create Table for Test Datasets
create table linked_lists (
    id int not null,
    prev_id int,
    value double
);

create table directed_acyclic_graphs (
    id int not null,
    prev_id int,
    value double
);

create table communities (
    id int not null,
    prev_id int
);

-- Populating Tables
insert into linked_lists values
    (1, null, 3),
    (2, 1, 5),
    (3, 2, 8),
    (4, null, 2),
    (5, 4, 10),
    (6, null, 9);

insert into directed_acyclic_graphs values
    (1, null, 3),
    (2, 1, 5),
    (3, 2, 8),
    (4, 2, 2),
    (5, 3, 10),
    (6, null, 9),
    (7, 4, 15),
    (8, 6, 17),
    (9, null, 5),
    (10, 8, 13),
    (11, 6, 1),
    (12, 9, 9);

insert into communities values
    (1, 2),
    (2, null),
    (3, 1),
    (1, 6),
    (4, 2),
    (5, null),
    (5, 3),
    (6, 5),
    (7, 8),
    (8, 7),
    (9, 9),
    (9, null),
    (10, null);
