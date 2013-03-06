REBAR=./rebar

all: compile

small: compile-small

compile: get-deps
	$(REBAR) compile

compile-small:
	rebar compile skip_deps=true

get-deps:
	$(REBAR) get-deps

shell: compile
	erl -pa deps/*/ebin \
		apps/*/ebin \
	    -s vocabio_app  start\
	    -config etc/app.config \
	    -name vocabio@127.0.0.1

rel: compile rel-clean
	$(REBAR) generate

rel-clean:
	rm -rf rel/vocabio

clean:
	$(REBAR) clean skip_deps=true
