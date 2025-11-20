docker-compose up -d
docker ps
docker exec -it event-platform-db psql -U admin -d event_platform
    \dt
    SELECT * FROM Users LIMIT 3;
    \q
docker exec -i event-platform-db psql -U admin -d event_platform < init-scripts/03-dml-operations.sql
docker exec -i event-platform-db psql -U admin -d event_platform < init-scripts/04-aggregation-queries.sql
docker exec -i event-platform-db psql -U admin -d event_platform < init-scripts/05-join-queries.sql
docker exec -i event-platform-db psql -U admin -d event_platform < init-scripts/06-views.sql
docker exec -it event-platform-db psql -U admin -d event_platform -c "\dv"
docker exec -it event-platform-db psql -U admin -d event_platform -c "SELECT * FROM TopRevenueEvents;"


http://localhost:8080
    admin@admin.com
    admin


docker-compose down
docker-compose down -v