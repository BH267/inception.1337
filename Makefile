NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml

all: up

build:
	docker-compose -f $(COMPOSE_FILE) build

up: build
	docker-compose -p $(NAME) -f $(COMPOSE_FILE) up -d 

down:
	docker-compose -f $(COMPOSE_FILE) down

re: down up

clean:
	docker system prune -f

fclean: down
	docker volume prune -f

.PHONY: all build up down re clean fclean
