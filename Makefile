
BASH = $(wildcard bash/*.bash)
ZSH = $(wildcard zsh/_*)

SCRIPTS = $(sort $(notdir $(basename $(wildcard specs/*.yaml) ) ) )

COMP = ${SCRIPTS:%=comp/%.comp}

all: bash zsh comp README.md

$(SCRIPTS):
	$(MAKE) bash/$@.bash
	$(MAKE) zsh/_$@

.PHONY: zsh bash comp
zsh: check $(ZSH)
bash: check $(BASH)
comp: $(COMP) comp/complete-shell.tsv

zsh/_%: specs/%.yaml
	appspec completion $< --zsh > $@
zsh/_GET: specs/lwp-request.yaml
	appspec completion $< --name GET --zsh > $@
zsh/_HEAD: specs/lwp-request.yaml
	appspec completion $< --name HEAD --zsh > $@
zsh/_POST: specs/lwp-request.yaml
	appspec completion $< --name POST --zsh > $@

bash/%.bash: specs/%.yaml
	appspec completion $< --bash > $@
bash/GET.bash: specs/lwp-request.yaml
	appspec completion $< --name GET --bash > $@
bash/HEAD.bash: specs/lwp-request.yaml
	appspec completion $< --name HEAD --bash > $@
bash/POST.bash: specs/lwp-request.yaml
	appspec completion $< --name POST --bash > $@

comp/%.comp: specs/%.yaml
	perl tools/app-spec-to-complete-shell.pl $< > $@

comp/complete-shell.tsv: $(wildcard comp/*.comp)
	complete-shell generate-index comp/ > $@

check:
	@which appspec >/dev/null || (echo "appspec not installed" && exit 1)

README.md: specs/*.yaml
	perl tools/update-readme.pl
