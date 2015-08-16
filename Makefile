

tidy:
	perltidy $$(find . -name '*.pm') $$(find . -name '*.t') test-driver webhook-receiver

critic:
	perlcritic $$(find . -name '*.pm') $$(find . -name '*.t') test-driver webhook-receiver

clean:
	find . -name '*.bak' -delete


modules: t/00-load.sh
	t/00-load.sh > t/00-load.t
	perltidy t/00-load.t
	rm t/00-load.t.bak

test: modules
	prove  --shuffle t/
