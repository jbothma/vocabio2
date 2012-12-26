all: compile

compile: get-deps
	rebar compile

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
