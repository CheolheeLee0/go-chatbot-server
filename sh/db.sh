docker exec -it dc58368b1099 psql -U postgres -d testdb

GRANT ALL PRIVILEGES ON DATABASE testdb TO postgres;