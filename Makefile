all: compile

small: compile-small

compile: get-deps
	rebar compile

compile-small:
	rebar compile skip_deps=true

get-deps:
	rebar get-deps

shell: compile
	erl -pa deps/*/ebin \
		apps/*/ebin \
	    -s vocabio_app  start\
	    -config etc/app.config \
	    -name vocabio@127.0.0.1

rel: compile rel-clean
	rebar generate

rel-clean:
	rm -rf rel/vocabio

clean:
	rebar clean skip_deps=true
