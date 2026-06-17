# Theatre Show Management System - SQL Schema & Sample Queries

A normalized database schema and sample queries for a theatre and show management system, similar to BookMyShow.

## 📂 Project Structure

- [`schema.sql`](bookmyshow/schema.sql): Complete normalized database schema (1NF, 2NF, 3NF, BCNF)
- [`sample_data.sql`](bookmyshow/sample_data.sql): Sample data for movies, theatres, shows, etc.
- [`queries_p2.sql`](bookmyshow/queries_p2.sql): 11 advanced SQL queries using window functions, CTEs, etc.

## 🚀 Features

### Schema (`schema.sql`)
- 10 normalized tables with proper relationships
- Supports multiple movies, theatres, screens, and shows
- Seat management with different types (REGULAR, PREMIUM, RECLINER, BALCONY)
- Show scheduling with date, time, language, format, and pricing
- Many-to-many relationships for movie genres and shows

### Sample Data (`sample_data.sql`)
- 4 movies with detailed information
- 4 theatres across multiple cities
- Multiple screens per theatre
- Sample seat data and pricing
- Show data for different dates and times

### Sample Queries (`queries_p2.sql`)
1. **Movie popularity**: Rank movies by number of shows
2. **City-wise movies**: List movies screened in each city
3. **Weekend shows**: Shows scheduled on weekends
4. **Price analysis**: Show price distribution by seat type
5. **Theatre capacity**: Total seats per theatre
6. **Upcoming movies**: Movies with future release dates
7. **Peak hours**: Busiest show time slots
8. **Genre breakdown**: Count of movies per genre
9. **Theatre occupancy**: Calculate percentage occupancy
10. **Price tiers**: Show price range by movie
11. **Daily schedule**: Complete schedule for a specific date

## 🛠️ Prerequisites

- MySQL Server (v5.7 or higher)
- SQL client (MySQL Workbench, DBeaver, or command-line)

## 🚀 Setup

1. **Create database**
   ```sql
   CREATE DATABASE bookmyshow;
   USE bookmyshow;
   ```

2. **Run schema**
   ```sql
   SOURCE bookmyshow/schema.sql;
   ```

3. **Add sample data**
   ```sql
   SOURCE bookmyshow/sample_data.sql;
   ```

4. **Run queries**
   ```sql
   SOURCE bookmyshow/queries_p2.sql;
   ```

## 💡 Usage

**View schema:**
```sql
DESCRIBE Movie;
DESCRIBE Show;
```

**Check sample data:**
```sql
SELECT * FROM Movie LIMIT 5;
SELECT * FROM Show LIMIT 5;
```

**Run specific query:**
```sql
-- Movie popularity ranking
SELECT 
    movie_id, 
    title, 
    show_count,
    RANK() OVER (ORDER BY show_count DESC) as rank
FROM (
    SELECT 
        m.movie_id, 
        m.title, 
        COUNT(s.show_id) as show_count
    FROM Movie m
    JOIN Show s ON m.movie_id = s.movie_id
    GROUP BY m.movie_id, m.title
) subquery;
```

## 📚 SQL Features Used

### Schema
- Primary keys, foreign keys
- `AUTO_INCREMENT` for automatic ID generation
- `ENUM` data type for seat types
- `UNIQUE` constraints for data integrity
- `ON DELETE CASCADE` for proper relationship handling

### Queries
- **Window functions**: `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, `LAG()`
- **CTEs**: Common Table Expressions for modular queries
- **Subqueries**: Nested queries for complex logic
- **Aggregate functions**: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`
- **Date functions**: `EXTRACT()`, `DAYNAME()`, `DATE()`, `MONTH()`
- **String functions**: `UPPER()`, `TRIM()`, `CONCAT()`

## 🤝 Contributing

Feel free to fork, modify, and improve!

## 📝 License

Public Domain

## 👨‍💻 Author

- VIKAS
