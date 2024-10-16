
target_mesa=gpu-setup-smokecheck
# options for target_mesa =
#   gpu-setup-smokecheck
.PHONY: run-docker-mesa
run-docker-mesa:
	VIDEO_GROUP_NUMBER=$(shell getent group video | cut -d: -f3) \
	RENDER_GROUP_NUMBER=$(shell getent group render | cut -d: -f3) \
	CARD_NUMBER=$(shell find /dev/dri -name 'card*' -print -quit | head -n 1) \
	DOCKERFILE=infra/amdgpu-llm.Dockerfile \
	docker compose -f infra/docker-compose.yaml run \
	 --service-ports --remove-orphans --build ${target_mesa}