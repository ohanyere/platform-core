.PHONY: validate validate-policies validate-crossplane validate-gitops docs

validate: validate-policies validate-crossplane validate-gitops docs
	@bash -n scripts/*.sh
	@echo "Local static validation completed"

validate-policies:
	@./scripts/validate-policies.sh

validate-crossplane:
	@./scripts/validate-crossplane.sh

validate-gitops:
	@./scripts/validate-gitops.sh

docs:
	@test -s README.md
	@test -s docs/architecture.md
	@test -s docs/repository-structure.md
	@echo "Documentation files are present"
