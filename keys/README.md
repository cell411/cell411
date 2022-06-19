These are all of the secrets which are required by cell411 to talk to servers
and such.

They are encrypted to the whole list of devs.

In order to maintain this, there is a keys/devs directory, which should
cointain a gpg public key for each developer who needs to build and test
against production.

This is still primitive.  I'll be adding a script to decrypt the files,
and move the decrypted version to the position where it is required.

 * cell411_keystore.jks.asc is the keystore file which is used by android
   studio to sign the app.

 * decrypt.sh will decrypt one or more files and save the result with the same
   name, minus the .asc extension.

 * devs/ is the directory with the developer keys
 
 * encrypt.sh will encrypt the files so they can be decripted by any developer.

 * Secrets.h.asc is an objective c header which contains the secrets required
   by the iOS verion

 * secrets.xml.asc is an android resource file which contains the secrets
   required by the android version


# tl;dr

```
cd keys
bash decrypt.sh secrets.xml.asc
cd ..
mv keys/secrets.xml $(dirname $(find -name config.xml))
```
