GIT = git
GITSTATUS := $(shell git diff-index --quiet HEAD . 1>&2 2> /dev/null; echo $$?)
DEPLOY_BRANCH = DEPLOY_7DRL_PREP
DEPLOY_BRANCH = master
DEV_BRANCH = dev
QUADPLAY_ROOT = /Users/Ed/projects/quadplay-dev/

GAME_NAME = ld48-mrawde
GAME_VERSION = 1.0.0

ITCH_GAME_NAME=ld48-mrawde
ITCH_RELEASE_USER=mrawde
ITCH_RELEASE_FILE = $(ITCH_GAME_NAME).$(GAME_VERSION).zip

DEPLOY_USER = mrawde
DEPLOY_REPO_NAME = ld48-mrawde
DEPLOY_REMOTE = git@github.com:$(DEPLOY_USER)/$(DEPLOY_REPO_NAME).git

sprite_pngs := GroundTiles.png TeamColors.png TitleScreen.png Truck.png Cursor.png
sound_wavs :=

all: sprites sounds
	
sprites: $(sprite_pngs)
	@echo "Updating all sprites..."
	@$(QUADPLAY_ROOT)/tools/sprite_json_generator.py -u

%.png : aseprite/%.aseprite
	scripts/export_aseprite $<

sounds: $(sound_wavs)
	@echo "no-op"

%.mp3 : sfx/%.wav
	lame $< $@

.PHONY: all sprites sounds

# this target deploys to a github repo that you can then point at with a url like:
# https://morgan3d.github.io/quadplay/console/quadplay.html?game=https://<USER_NAME>.github.io/<DEPLOY_REPO_NAME>/<GAME_NAME>.game.json
# the target needs to be something like: DEPLOY_REMOTE = git@github.com:<USER_NAME>/<DEPLOY_REPO_NAME>.git
deploy:
ifneq ($(GITSTATUS), 0)
	$(error "Git repository is dirty, cannot deploy. Run 'git status' for more info")
endif
	@echo "Moving deploy branch"
	$(GIT) checkout -B $(DEPLOY_BRANCH)
	$(GIT) reset --hard $(DEV_BRANCH)
	$(GIT) init
	$(GIT) add .
	$(GIT) commit -m "Snapshot for deployment"
	$(GIT) remote add deploy $(DEPLOY_REMOTE)
	$(GIT) push deploy master --force
	@rm -rf .git
	$(GIT) checkout $(DEV_BRANCH)
	@echo "Deploy branch is now moved." 
	@echo "To test visit: https://morgan3d.github.io/quadplay/console/quadplay.html?game=https://"$(DEPLOY_USER)".github.io/$(DEPLOY_REPO_NAME)/$(GAME_NAME).game.json"

# make a zipfile for itch
itch: butler/butler
ifneq ($(GITSTATUS), 0)
	$(error "Git repository is dirty, cannot deploy. Run 'git status' for more info")
endif
	@echo "running from: " $(PWD)
	@echo "Remove previous release if it exists."
	-@rm -rf $(ITCH_RELEASE_FILE)
	python3 $(QUADPLAY_ROOT)/tools/export.py -z $(ITCH_RELEASE_FILE) .
	@echo "done, made $(PWD)/$(ITCH_RELEASE_FILE)"
	butler/butler push $(ITCH_RELEASE_FILE) $(ITCH_RELEASE_USER)/$(ITCH_GAME_NAME):html

butler/butler:
	@echo "updating butler..."
	bash scripts/getbutler.sh
