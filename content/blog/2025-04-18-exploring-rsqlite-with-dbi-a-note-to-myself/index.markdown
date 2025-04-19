---
title: 'Exploring `RSQLite` With `DBI`: A Note To Myself'
author: Ken Koon Wong
date: '2025-04-18'
slug: rsqlite
categories: 
- r
- R
- sqlite
- rsqlite
- dbi
- plumber
tags: 
- r
- R
- sqlite
- rsqlite
- dbi
- plumber
excerpt: I messed around with DBI and RSQLite and learned it's actually pretty simple to use in R - just connect, write tables, and use SQL queries without all the complicated server stuff. Thanks to Alec Wong for suggesting this!
---

> I messed around with DBI and RSQLite and learned it's actually pretty simple to use in R - just connect, write tables, and use SQL queries without all the complicated server stuff. Thanks to Alec Wong for suggesting this!

<p align="center">
  <img src="database.jpg" alt="image" width="60%" height="auto">
</p>

## Motivation
After our last [blog](https://www.kenkoonwong.com/blog/plumber/), my friend Alec Wong suggested that I switch storing data from CSV files to SQLite when building Plumber API. I had no idea that CSV files can get corrupted when multiple users hit the API at the same time! SQLite handles this automatically and lets you validate your data without needing to set up any complicated server stuff. It's actually pretty straightforward, here is a note to myself of some simple and frequent functions.

## Objectives 
- [Connecting to A Database](#database)
- [List Tables](#table)
- [Check Data](#check)
- [Add Data](#add)
- [Query Data](#query)
  - [Using glue_sql](#glue_sql)
- [Remove Data](#delete)
- [Disconnect](#disconnet)
- [Lessons Learnt](#lessons)




## Connecting to A Database {#database}

``` r
library(DBI)
library(RSQLite)
library(tidyverse)

con <- dbConnect(drv = RSQLite::SQLite(), "test.sqlite")
```

That's it! If the file does not exist, it will create one. 

## List Tables {#table}
Let's write an sample dataframe and write to a table on the database

``` r
# example df
employees <- tibble(
  name = c("John Doe", "Jane Smith", "Bob Johnson", "Alice Brown"),
  department = c("IT", "HR", "Finance", "Marketing"),
  salary = c(75000, 65000, 80000, 70000)
)

# write df to dataframe
dbWriteTable(conn = con, name = "employees", value = employees)

# See What talbes are in the database
tables <- dbListTables(con)
tables
```

```
## [1] "employees"
```

Pretty straightforward! 

## Check Data {#check}

``` r
## Method 1
employees_db <- tbl(con, "employees")
employees_db |> collect()
```

```
## # A tibble: 4 × 3
##   name        department salary
##   <chr>       <chr>       <dbl>
## 1 John Doe    IT          75000
## 2 Jane Smith  HR          65000
## 3 Bob Johnson Finance     80000
## 4 Alice Brown Marketing   70000
```

Have to use `collect` to return a df. We can also do this instead


``` r
## Method 2
dbGetQuery(con, "select * from employees")
```

```
##          name department salary
## 1    John Doe         IT  75000
## 2  Jane Smith         HR  65000
## 3 Bob Johnson    Finance  80000
## 4 Alice Brown  Marketing  70000
```


## Add Data {#add}

``` r
## Create New Row of Data
new_employee <- data.frame(
  name = "Sarah Johnson",
  department = "Research",
  salary = 78000
)

## Write to existing table
dbWriteTable(conn = con, name = "employees", value = new_employee, append = TRUE)

tbl(con, "employees") |> collect()
```

```
## # A tibble: 5 × 3
##   name          department salary
##   <chr>         <chr>       <dbl>
## 1 John Doe      IT          75000
## 2 Jane Smith    HR          65000
## 3 Bob Johnson   Finance     80000
## 4 Alice Brown   Marketing   70000
## 5 Sarah Johnson Research    78000
```

Dataframe must contain the same column names and number. Else, won't work

``` r
## New column
new_employee <- data.frame(
  name = "Sarah Johnson",
  department = "Research",
  salary = 78000,
  something_new = 12321321
)

dbWriteTable(con, "employees", value = new_employee, append = T)
# OR
# dbAppendTable(con, "employees", new_employee)
```

```{echo=F}
Error: Columns `something_new` not found
```

## Query Data {#query}
#### Filter

``` r
dbGetQuery(con, "select * from employees where department = 'Research'")
```

```
##            name department salary
## 1 Sarah Johnson   Research  78000
```

#### Filter With Matching Operator

``` r
dbGetQuery(con, "select * from employees where name like '%john%'")
```

```
##            name department salary
## 1      John Doe         IT  75000
## 2   Bob Johnson    Finance  80000
## 3 Sarah Johnson   Research  78000
```

notice that it's case insensitive when we use `like`. 


``` r
dbGetQuery(con, "select * from employees where name like 's%'")
```

```
##            name department salary
## 1 Sarah Johnson   Research  78000
```

#### Group Department and Return Average Salary

``` r
dbGetQuery(con, "select department, avg(salary) as avg_salary 
           from employees 
           group by department")
```

```
##   department avg_salary
## 1    Finance      80000
## 2         HR      65000
## 3         IT      75000
## 4  Marketing      70000
## 5   Research      78000
```

#### Sum Salary With New Column Name

``` r
dbGetQuery(con, "select sum(salary) as total_salary from employees")
```

```
##   total_salary
## 1       368000
```

#### Count Number of Departments

``` r
dbGetQuery(con, "select count(distinct department) as distinct_department 
           from employees")
```

```
##   distinct_department
## 1                   5
```

### Using `glue_sql` {#glue_sql}

``` r
var <- c("name","department")
table <- "employees"
query <- glue::glue_sql("select {`var`*} from {`table`}", .con = con)
dbGetQuery(con, query)
```

```
##            name department
## 1      John Doe         IT
## 2    Jane Smith         HR
## 3   Bob Johnson    Finance
## 4   Alice Brown  Marketing
## 5 Sarah Johnson   Research
```
Notice the asterisk `(*)` after `{var}` - this tells `glue_sql()` to join the elements with commas automatically. `glue_sql` provides an `f-string` feel to the code.

## Remove Data {#delete}

``` r
## Delete Using Filter
dbExecute(con, "delete from employees where name = 'Sarah Johnson'")
```

```
## [1] 1
```

``` r
dbGetQuery(con, "select * from employees")
```

```
##          name department salary
## 1    John Doe         IT  75000
## 2  Jane Smith         HR  65000
## 3 Bob Johnson    Finance  80000
## 4 Alice Brown  Marketing  70000
```

#### Remove With Filter

``` r
dbGetQuery(con, "select * from employees")
```

```
##          name department salary
## 1    John Doe         IT  75000
## 2  Jane Smith         HR  65000
## 3 Bob Johnson    Finance  80000
## 4 Alice Brown  Marketing  70000
```

``` r
dbExecute(con, "delete from employees where salary >= 75000 and department = 'Finance'")
```

```
## [1] 1
```

``` r
dbGetQuery(con, "select * from employees")
```

```
##          name department salary
## 1    John Doe         IT  75000
## 2  Jane Smith         HR  65000
## 3 Alice Brown  Marketing  70000
```

Notice how `=` requires case sensitive `F` on `Finance` to filter accurately? Bob no longer in dataframe!




## Disconnect {#disconnect}

``` r
dbDisconnect(con)
```

## Acknowledgement
Thanks again to Alec for suggesting improvements on our previous project! 

#### For Completeness Sake of Prior `plumber.R`

``` r
library(plumber)
library(tidyverse)
library(lubridate)
library(DBI)
library(RSQLite)

path <- "" #set your own path
con <- dbConnect(RSQLite::SQLite(), paste0(path,"migraine.sqlite"))

#* @apiTitle Migraine logger

#* Return HTML content
#* @get /
#* @serializer html
function() {
  
  # Return HTML code with the log button
  html_content <- '
     <!DOCTYPE html>
     <html>
     <head>
       <title>Migraine Logger</title>
     </head>
     <body>
       <h1>Migraine Logger</h1>
       <button id="submit">Oh No, Migraine Today!</button>
       <div id="result" style="display: none;"></div>
       
      <script>
       document.getElementById("submit").onclick = function() {
          fetch("/log", {
            method : "post"
          })
          .then(response => response.json())
          .then(data => {
            const resultDiv = document.getElementById("result");
            resultDiv.textContent = data[0];
            resultDiv.style.display = "block";
          })
          .catch(error => {
            const resultDiv = document.getElementById("result");
            resultDiv.textContent = error.message
          })
       };
      </script>
      
     </body>
     </html>
     '
  return(html_content)
}

#* logging 
#* @post /log
function(){
  date_now <- tibble(date=Sys.time())
  dbWriteTable(con, "migraine", date_now, append = TRUE)
  list(paste0("you have logged ", date_now$date[1], " to migraine database"))
}

#* download data
#* @get /download
#* @serializer contentType list(type="text/csv")
function(){
  # Just return the raw CSV content
  df <- tbl(con, "migraine") |> collect() |> mutate(date = as_datetime(date, tz = "America/New_York"))
  format_csv(df)
}

#* Check datetime on browser
#* @get /table
function(){
  df <- tbl(con, "migraine") |> collect() |> mutate(date = as_datetime(date, tz = "America/New_York"))
  list(df)
}
```


## Lessons Learnt {#lessons}
- Lots of goodies on [DBI](https://dbi.r-dbi.org/) official website
- Learnt how to set up SQLite on Rpi, incorporated it on the previous migraine logger
- Definitely need to be comfortable with SQL to use this
- Might be a good idea to add this to the pressure logger too! Maybe in the same database but different table!

<br>


If you like this article:
- please feel free to send me a [comment or visit my other blogs](https://www.kenkoonwong.com/blog/)
- please feel free to follow me on [BlueSky](https://bsky.app/profile/kenkoonwong.bsky.social), [twitter](https://twitter.com/kenkoonwong/), [GitHub](https://github.com/kenkoonwong/) or [Mastodon](https://med-mastodon.com/@kenkoonwong)
- if you would like collaborate please feel free to [contact me](https://www.kenkoonwong.com/contact/)
