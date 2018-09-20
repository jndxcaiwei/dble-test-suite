# Created by zhaohongjie at 2018/9/5
Feature: subquery execute plan should be optimized for ER/Global table join #dble github issue #685
  As developer suggestion, the "explain ...(query)" resultset line count can indicate whether the query plan is optimized

  Scenario: check ER tables subquery execute plan optimized
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="table_a" dataNode="dn1,dn2" rule="hash-two" />
        <table name="table_b" dataNode="dn1,dn2" rule="hash-two" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                          | expect    | db     |
      | test | 111111 | conn_0 | False    | drop table if exists table_a | success   | mytest |
      | test | 111111 | conn_0 | False    | drop table if exists table_b | success   | mytest |
      | test | 111111 | conn_0 | False    | create table table_a (id int,c_flag char(255))| success   | mytest |
      | test | 111111 | conn_0 | True     | create table table_b (id int,c_flag char(255))| success   | mytest |
    Then get query plan and make sure it is optimized
      |query | expect_result_count |
      |explain select * from table_a a, table_b b on a.id =b.id | 4 |
      |explain select count(*) from ( select a.id from table_a a join table_b b on a.id =b.id) x; | 7 |

  Scenario: check Global tables subquery execute plan optimized
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="table_a" dataNode="dn1,dn2" type="global" />
        <table name="table_b" dataNode="dn1,dn2" type="global" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                          | expect    | db     |
        | test | 111111 | conn_0 | False    | drop table if exists table_a | success   | mytest |
        | test | 111111 | conn_0 | False    | drop table if exists table_b | success   | mytest |
        | test | 111111 | conn_0 | False    | create table table_a (id int,c_flag char(255)) | success   | mytest |
        | test | 111111 | conn_0 | True     | create table table_b (id int,c_flag char(255)) | success   | mytest |
    Then get query plan and make sure it is optimized
        |query | expect_result_count |
        |explain select * from table_a a, table_b b on a.id =b.id | 2 |
        |explain select count(*) from ( select a.id from table_a a join table_b b on a.id =b.id) x; | 2 |