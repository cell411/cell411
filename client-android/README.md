## Setup:

### Android

* If you're working with me on the official version, I'll get a PGP public key from you, and add you
  to the list of people for whome keys/secrets.xml.asc is encrypted.

* having decrypted secrets.xml.asc, you'll want to put it in the res directory.
  Android loves deep source keys, so I do this:

  mv secrets.xml $(find -name strings.xml  | xargs dirname )

  For non-unix people, that finds a file called strings.xml (there is only
  one in the project), and prints out the name.  The name is then choped
  down to just the directory part by dirname, and the result is substibuted
  into the mv (or move) command.  The genius of unix is that it allows you
  to take such simple tools, and put them together to do the impossible with
  difficulty, and difficult things easily.  That will be my last sermon.  Here.

* If not, you'll need your own credentials to a parse-server ( which you can
  easily host yourself, if you run linux ) and (if you want to stream video)
  to a wowza server.  Also, you'll need an api key for google maps, and you'll
  need to be set up with firebase, so you can send push messages.

