Vocabio
=======

This is an online tool for storing and reviewing words. An example of its use is
recording unknown words for improving vocabulary while reading a foreign language.
The utility of this tool might be extended with integration with other services,
e.g. Folkets Lexicon or similar for other languages, pronunciation guides, browser
or other application plugins. The main goal of this site is to provide a backend
for reducing the friction when trying to record and review words.

This is a rewrite of the first iteration of the site, hence the vocabio2 repo
name. I'll probably change that when all the old functionality is replaced and
this goes live.

Features
--------

* OpenID authentication
* Add word
* List words
* Delete words

Desired features
----------------

* known/unknown status on word
* store word context
  * e.g. if I add a word from a browser plugin while reading on a website, the
context is the URL, timestamp and sentence or position on page. Perhaps a special
URL can be constructed which lets the plugin return me to that context and
highlight the word during review.
* REST API
  * Documented at doc/API.md

Desired integration
-------------------

* browser plugin
  * Should be trivial to select and add a word while reading something online
  * perhaps highlight words in a page which are in a user's list of unknown words
* synonymns, descriptions, translations, pronunciation
  * Folkets Lexicon provides some and links to pronunciation recordings
* produce podcasts for review
  * word, meaning, context where found, example uses

Code
----

The code for this project will generally be prefixed with vocabio_ or vbo_.
The latter is indended to be a short form of the former.

The MVC pattern is used for organising much of the code. Controllers are generally
implemented in the vbo_res_ modules, where res stands for resource (as in REST).
Views are currently directly rendered from Django Template Language templates
which become _dtl erlang modules. They will probably be wrapped in vbo_view_
modules. Models are implemented in vbo_model_ modules.


Building
--------

run ```make``` to compile.

```make rel``` produces an erlang release.

Running
-------

```make shell``` starts an erlang VM running the site, listening on 8080.

The browser view will be based on the REST API but returning HTML instead of JSON.

Reporting bugs
--------------

Issues with the site should be reported on its github repo.

Issues concerning
security should preferably be reported privately to my email address associated
with my github account so that I can fix it before making it public, but if I
don't deal with it, it should be reported on the github repo so that someone else
can provide a fix.

Feedback
--------

Other feedback on the code, design, architecture or concept is very welcome
directly to me or as issues on the github repo if appropriate.

If this picks up as a popular language learning tool, I'd like to extend this
service with a language learning forum and/or chat site where users can arrange
chat sessions or voice calls to practise various languages with others that
are more capable in that language. Something like that probably already exists
so integration with other sites is also an option. One idea of such an extension
is that users can ask for help or comment on words they're learning, e.g. its
uses, or for feedback on practise sentenses written using the word being learnt.

License
-------

Not licensed yet. All copyright is reserved.

The idea is that this will be open for people to copy, contribute to, etc. I
mainly want a service like this to exist for my own use. I'm happy if others can
benefit from it. If someone else makes a site like this (even using this code),
there's less work for me! Feel free to contact me. I will probably release this
under an open source license.