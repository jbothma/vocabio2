Vocabio API
===========

By default, an HTML view of the resource is returned. The return type can be
selected using the HTTP `Accept` header. Supported content-types are
 `text/html` and `application/json`.

/user/UID
---------

### GET

* return this resource
* list resources available under this resource?
  * e.g. say that /user/UID/word exists?

### Example

``` json
{ "nickname" : "JD",
  "words" :
  [ { "word" : "aardvark",
      "uri" : "/user/UID/ardvark" },
    { "word" : "zulu",
      "uri" : "/user/UID/zulu" }
  ],
  "openid" : "
}
```

/user/UID/word
--------------

### POST

* create or update the given word
* return the resource URL of the word

/user/UID/word/WORD_ID
----------------------

### GET

* return this resource
  * indicate what resources exist below this resource?

### Example

``` json
{ "word" : "aardvark" }
```
