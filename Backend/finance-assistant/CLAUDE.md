# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BeztaMy Finance Assistant is a Spring Boot backend application that provides a RESTful API for a personal finance management system. It serves a Flutter mobile application with JWT-based authentication, transaction tracking, category management, and financial analytics features.

**Stack:**
- Java 21
- Spring Boot 4.0.0
- PostgreSQL database
- JWT authentication (JJWT 0.11.5)
- Maven build system

## Database Setup

Start the PostgreSQL database using Docker:

```bash
docker run --name finance-db \
  -e POSTGRES_DB=finance_assistant_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin \
  -p 5432:5432 \
  -d postgres
```

**Database connection details:**
- URL: `jdbc:postgresql://localhost:5432/finance_assistant_db`
- Username: `postgres`
- Password: `admin`
- Port: `5432`

The application runs on port `8085`.

## Development Commands

### Build and Run
```bash
# Clean and build the project
./mvnw clean install

# Run the application
./mvnw spring-boot:run

# Run with specific profile (if needed)
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### Testing
```bash
# Run all tests
./mvnw test

# Run a specific test class
./mvnw test -Dtest=FinanceAssistantApplicationTests

# Run tests with coverage
./mvnw test jacoco:report
```

### Package
```bash
# Create executable JAR
./mvnw package

# Skip tests during packaging
./mvnw package -DskipTests
```

## Architecture

### Package Structure

```
com.BeztaMy.finance_assistant/
├── config/          # Security and application configuration
├── controller/      # REST API endpoints
├── dto/             # Data Transfer Objects for API requests/responses
├── entity/          # JPA entities (domain models)
├── enums/           # Enumerations (TransactionType, Frequency)
├── repository/      # JPA repositories (data access layer)
└── service/         # Business logic layer
```

### Core Entities and Relationships

**User** (implements `UserDetails` for Spring Security)
- Primary authentication entity
- Email is used as username
- Stores profile picture as BYTEA
- Has financial planning fields: `monthlyBudget`, `riskTolerance`, `financialGoals`

**Transaction**
- Belongs to a User (via `userId` column, not a JPA relationship)
- References a Category via `@ManyToOne` relationship
- Supports recurring transactions with `isRecurring`, `frequency`, `nextExecutionDate`, `endDate`
- Types: INCOME or EXPENSE
- Stores amounts as `BigDecimal` with precision 19, scale 2

**Category**
- Can be user-specific or default/global (via `isDefault` flag and nullable `userId`)
- Has type (for categorizing income vs expense categories)
- No bidirectional relationship to Transaction

### Security Architecture

**JWT-based stateless authentication:**
1. `SecurityConfig` configures the security filter chain with stateless session management
2. `JwtAuthenticationFilter` (extends `OncePerRequestFilter`) intercepts requests and validates JWT tokens from the `Authorization: Bearer <token>` header
3. Public endpoints: `/api/auth/**` (login, register)
4. All other endpoints require valid JWT authentication
5. CORS is configured to allow all origins (development mode - see `SecurityConfig:44`)

**Password encryption:** BCrypt via `PasswordEncoder` bean

**JWT configuration:**
- Secret and expiration defined in `application.properties`
- Token expiration: 86400000ms (24 hours)
- `JwtService` handles token generation, validation, and claims extraction

### Controller Patterns

Controllers follow a consistent pattern:
- `@RestController` with `@RequestMapping("/api/{resource}")`
- `@CrossOrigin(origins = "*")` for CORS
- Standard CRUD endpoints plus specialized endpoints
- Use `@Valid` for DTO validation
- Return `ResponseEntity<T>` for type-safe responses

### Transaction Dashboard Endpoints

The backend provides specialized Flutter dashboard endpoints:
- `/api/transactions/dashboard/balance` - Current balance summary (totalIncome, totalExpense, currentBalance)
- `/api/transactions/dashboard/monthly-summary` - Monthly income vs expenses for bar charts
- `/api/transactions/dashboard/recent` - Recent transactions list
- `/api/transactions/dashboard/spending-categories` - Spending by category with percentages and colors for pie charts
- `/api/transactions/dashboard/financial-trends` - Cumulative balance over time for line charts

**Important:** Category colors in pie charts are randomly assigned using a predefined color palette in `TransactionService:27-46`.

### Repository Query Patterns

Repositories use:
- Spring Data JPA method name queries (e.g., `findByUserId`)
- Custom `@Query` with JPQL for complex filtering
- Example: `TransactionRepository.findByFilters()` supports optional date range, category, and type filters

### Service Layer Patterns

Services contain business logic:
- Use `@Transactional` for operations that modify data
- Aggregate and transform data for dashboard endpoints
- Use Java Streams for filtering and mapping
- `BigDecimal` for all monetary calculations to avoid precision issues

### DTO Validation

DTOs use Jakarta validation annotations:
- `@NotNull`, `@NotBlank`, `@Size`, `@Email`, etc.
- Validated via `@Valid` in controllers
- Separate DTOs for requests and responses (e.g., `RegisterRequest`, `AuthResponse`)

## Key Implementation Notes

1. **User ID Handling:** Transactions store `userId` as a `Long` column rather than a JPA `@ManyToOne` relationship to User. This is an intentional design choice for performance.

2. **Email as Username:** The User entity implements `UserDetails` and uses email as the username (`getUsername()` returns email).

3. **Category Assignment:** Categories can be default (shared across users, `isDefault=true`, `userId=null`) or user-specific (`isDefault=false`, `userId=<userId>`).

4. **Recurring Transactions:** The schema supports recurring transactions but the cron/scheduler logic is not yet implemented in the codebase. Fields like `nextExecutionDate`, `endDate`, `isActive`, `frequency` are present for future implementation.

5. **Profile Pictures:** Stored as BYTEA in PostgreSQL, accessed as `byte[]` in Java.

6. **Hibernate DDL:** Set to `update` mode (`spring.jpa.hibernate.ddl-auto=update`) which auto-updates schema on entity changes.

## Configuration Files

**application.properties** (`src/main/resources/application.properties`):
- Database connection details
- JPA/Hibernate configuration with `show-sql=true` for debugging
- JWT secret and expiration
- Server port (8085)

**pom.xml:**
- Main class: `com.BeztaMy.finance_assistant.FinanceAssistantApplication`
- Lombok configured to be excluded from the final JAR

## Testing

Minimal test coverage currently exists. The only test is `FinanceAssistantApplicationTests` which verifies context loading.

When adding tests:
- Use `@SpringBootTest` for integration tests
- Use `@WebMvcTest` for controller tests
- Use `@DataJpaTest` for repository tests
- Test data should use test containers or H2 in-memory database
