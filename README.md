# graphs-in-sql
## Background
This repo contains algorithms for root node tracing and community detection of graphs in SQL. Root node tracing and community detection are fundamental tasks for finding appropriate cohorts in information retrieval and transactions. Unlike graph traversal algorithms that visit only one node at a time, root tracing and community detection can be conducted simultaneously for across all nodes. Therefore, we can leverage the highly efficient data joining operations implemented in the backend SQL. In the meantime, the algorithms in this repo can be easily adopted to the map-reduce frameworks.

## Input Format
All algorithms are implemented as stored procedures in sql, which take `in_tname` and `out_tname` as inputs. `in_tname` specifies the name of the input table, while `out_tname` specifies the name of the output table. All input tables need to contain two columns `id` and `prev_id`, where `id` uniquely defines each identity, and `prev_id` refers to the node the current one connects to. `prev_id` being `null` means that the current node has no out-going edges.

## Output Format
The output tables have two columns. For root tracing algorithms, the two columns are `id` and `root_id`, where for each `id`, it stores the `id` of the root node it connects to. If a node is a root node itself, then its `id` and `root_id` will be identical. For the community detection algorithm, the two columns are `id` and `label`, where each `label` uniquely defines a community, and each node has one and only one community assigned to it.

## Examples
If there is a way to sort the data such that all cohorts are consecutive `id`s and there are no interleavings among different cohorts, for example, if the graphs represent disjoint events connected using timestamps, then we can use the stored procedure `find_roots_ordered` to find the roots:
```sql
call find_roots_ordered('linked_lists', 'linked_lists_roots');
select * from linked_lists_roots;
```
To find a root of a general directed acyclic graphs, we should use the stored procedure `find_roots_dag`:
```sql
call find_roots_dag('directed_acyclic_graphs', 'dag_roots');
select * from dag_roots;
```
For a general graph that may or may not be acyclic, we can detect its communities using the stored procedure `detect_communities`:
```sql
call detect_communities('communities', 'comm_labels');
select * from comm_labels;
```
For all algorithms above, <strong>duplication of records has no impact on the results</strong>. In addition, if a node has a record with empty `prev_id` (i.e. no out-going edges) and another record with non-empty `prev_id`, then the record is treated as a non-root nodes with out-going edges. The presence of empty `prev_id` for non-root nodes does not impact the outcomes of any algorithms above. It makes it easier for on-going data transactions and updates after the initial setup of datasets.
