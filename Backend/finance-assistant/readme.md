docker run --name finance-db \
-e POSTGRES_DB=finance_assistant_db \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=admin \
-p 5432:5432 \
-d postgres