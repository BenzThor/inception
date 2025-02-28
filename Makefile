DOCKER_COMPOSE = docker compose -f ./srcs/docker-compose.yml
VOLUMES_DIR = ./.data
WORDPRESS_DIR = ${VOLUMES_DIR}/wp
MARIADB_DIR = ${VOLUMES_DIR}/mariadb
ENV_DIR = ./srcs/.env

# set up version numbers of Alpine, PHP and Architecture
ALPINE_WEBSITE = https://dl-cdn.alpinelinux.org/alpine/
ALPINE_VERSION = $(shell curl -s $(ALPINE_WEBSITE) | grep -oP 'v[0-9]+\.[0-9]+' | sort -V | uniq | tail -n 2 | head -n 1 | sed 's/^v//')
ifeq ($(ALPINE_VERSION),)
  $(error "Error: Failed to fetch Alpine version.")
endif
ARCHITECTURE = $(shell uname -m)
ifeq ($(ARCHITECTURE),)
  $(error "Error: Failed to fetch architecture.")
endif
PHP_VERSION = $(shell curl -s $(ALPINE_WEBSITE)v$(ALPINE_VERSION)/community/$(ARCHITECTURE)/APKINDEX.tar.gz | tar -xzO | strings | grep -oP '^P:php\d+' | sed 's/[^0-9]*//g' | sort -n | tail -n 1)
ifeq ($(PHP_VERSION),)
  $(error "Error: Failed to fetch PHP version.")
endif

all: create_dirs build up

print_versions:
	@/bin/echo -e "PHP Version\t$(PHP_VERSION)\n"
	@/bin/echo -e "Alpine Version:\t$(ALPINE_VERSION)\n"
	@/bin/echo -e "Architecture:\t$(ARCHITECTURE)\n"

create_volumes_dir:
	@mkdir -p ${VOLUMES_DIR}

create_dirs: create_volumes_dir
	@mkdir -p ${WORDPRESS_DIR}
	@mkdir -p ${MARIADB_DIR}

build: create_dirs
	@if ! grep -q "ALPINE_VERSION" $(ENV_DIR) && ! grep -q "PHP_VERSION" $(ENV_DIR); then \
		/bin/echo -e "ALPINE_VERSION=$(ALPINE_VERSION)\nPHP_VERSION=$(PHP_VERSION)" >> ./srcs/.env; \
	fi
	docker compose -f ./srcs/docker-compose.yml config
	$(DOCKER_COMPOSE) build

up: create_dirs
	${DOCKER_COMPOSE} up -d

down:
	${DOCKER_COMPOSE} down --rmi all

rm_images:
	${DOCKER_COMPOSE} --rmi all

logs:
	${DOCKER_COMPOSE} logs nginx wordpress mariadb

logs_%:
	${DOCKER_COMPOSE} logs $*

restart:
	${DOCKER_COMPOSE} restart nginx wordpress mariadb

shell_%:
	${DOCKER_COMPOSE} exec -it $* /bin/sh

clean: down
	${DOCKER_COMPOSE} down -v --rmi all --remove-orphans

fclean: clean
	if [ -d "./.data" ]; then \
		sudo chown -R ${USER}:${USER} ./.data; \
		rm -r $(VOLUMES_DIR); \
	fi
	docker system prune -f
	@sed -i '/ALPINE_VERSION/d; /PHP_VERSION/d' $(ENV_DIR)

re: fclean all

.PHONY: print_versions build up down logs logs_% restart rm_images re fclean clean shell_% create_dirs create_data_dir
