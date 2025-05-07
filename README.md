# Database Schema Optimization Projects

This repository contains several database projects implementing advanced database concepts, optimization techniques, and data modeling strategies across different database management systems (PostgreSQL, SQL Server, MySQL).

## Projects Overview

### 1. Coffee Shop Management System
The most comprehensive project showcasing:

#### Data Modeling
- Detailed Entity-Relationship Diagrams (ERD) for both operational database and data warehouse
- Normalized database design for efficient data management
- Implementation in both PostgreSQL and SQL Server

#### Query Optimization
- Advanced indexing strategies implemented in `final_index.sql`
- Efficient stored procedures and functions for:
  - Customer management
  - Order processing
  - Revenue calculations
  - Product rankings
- Performance-optimized triggers
- Data warehouse implementation with optimized views

#### Advanced Features
- Customer classification system
- Revenue analytics
- Gift exchange system
- Employee performance tracking
- Product inventory management

### 2. Movie Database (PostgreSQL)
- Focuses on query optimization through indexing
- Metadata management for movie information

### 3. Printer Management System (MySQL)
- Entity-Enhanced Relationship Diagram (EERD) implementation
- Trigger-based business logic
- Normalized database structure for printer resource management

### 4. Bus Ticket System (PostgreSQL)
- ERD-based data modeling for ticket booking system

## Key Features

### Query Optimization Techniques
- Strategic index creation for frequently accessed columns
- Optimized stored procedures and functions
- Efficient trigger implementations
- View materialization where appropriate

### Data Modeling Approaches
- Normalized database designs
- Clear entity relationships
- Careful consideration of data types
- Implementation of constraints for data integrity
- Both operational and analytical data models (as seen in Coffee Shop project)

### Performance Considerations
- Indexed views for frequent queries
- Efficient stored procedures
- Optimized data warehouse schema
- Strategic use of triggers for data consistency

## Implementation Details

- **PostgreSQL**: Coffee Shop system, Movie database, Bus Ticket system
- **SQL Server**: Alternative implementation of Coffee Shop system
- **MySQL**: Printer Management system

Each project includes:
- Database creation scripts
- Table definitions
- Index creation scripts
- Stored procedures/functions
- Triggers
- ERD/EERD diagrams