-module(vbo_unicode).

-export([normalize/2]).

normalize(nfc, UTF8Binary) ->
    CodepointList = unicode:characters_to_list(UTF8Binary),
    NFCCodepointList = ux_string:to_nfc(CodepointList),
    _NFCUTF8Binary = unicode:characters_to_binary(NFCCodepointList).
