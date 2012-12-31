all: compile

small: compile_small

compile: get-deps
	rebar compile

compile_small:
	rebar compile skip_deps=true

get-deps:
	rebar get-deps

shell: compile
	erl -pa deps/*/ebin \
		apps/*/ebin \
	    -s vocabio_app  start\
	    -config etc/app.config \
	    -name vocabio@127.0.0.1

clean:
	rebar clean skip_deps=true
