NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml

all: up

build:
	docker-compose -p $(NAME) -f $(COMPOSE_FILE) build

up: build
	docker-compose -p $(NAME) -f $(COMPOSE_FILE) up -d 

down:
	docker-compose -p $(NAME) -f $(COMPOSE_FILE) down

re: down up

hot-restart: down whole-clean up

clean:
	docker system prune -f

whole-clean: down clean
	docker volume prune -f
	sudo rm -rf /home/habenydi/data/{db,wp}/*
	sudo rm -rf /home/habenydi/data/db/.initialized

.PHONY: all build up down re clean fclean
