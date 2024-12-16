DOCKER_COMPOSE = docker compose -f ./srcs/docker-compose.yml
VOLUMES_DIR = ./.data
WORDPRESS_DIR = ${VOLUMES_DIR}/wp
MARIADB_DIR = ${VOLUMES_DIR}/mariadb

all: create_dirs build up

create_volumes_dir:
	@mkdir -p ${VOLUMES_DIR}

create_dirs: create_volumes_dir
	@mkdir -p ${WORDPRESS_DIR}
	@mkdir -p ${MARIADB_DIR}

build: create_dirs
	${DOCKER_COMPOSE} build

up: create_dirs
	${DOCKER_COMPOSE} up -d

down:
	${DOCKER_COMPOSE} down --rmi all

rm_images:
	${DOCKER_COMPOSE} --rmi all

logs:
	${DOCKER_COMPOSE} logs nginx wordpress logs mariadb

logs_%:
	${DOCKER_COMPOSE} logs $*

restart:
	${DOCKER_COMPOSE} restart nginx wordpress mariadb

shell_%:
	${DOCKER_COMPOSE} exec -it $* /bin/sh

clean: down
	${DOCKER_COMPOSE} down -v --rmi all --remove-orphans

fclean: clean
	docker system prune -f

re: fclean all

.PHONY: build up down logs logs_% restart rm_images re fclean clean shell_% create_dirs create_data_dir
