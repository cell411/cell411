features/files:

all:
	@echo "Choose a job"; exit 1

fuck:
	@echo makeFriends.js.mjs:1:x
	PARSE_FLAVOR=parse node makeFriends.js.mjs

revGeocode:
	PARSE_FLAVOR=parse node revgeocode.mjs

uploadProfilePic:
	@echo uploadProfilePic.mjs.out:1: output
	set -o pipefail ;  PARSE_FLAVOR=parse node uploadProfilePic.mjs  2>&1 | tee uploadProfilePic.mjs.out

fixDevUsers:
	@echo fixDevUsers.js.out:1: output
	node --trace-uncaught fixDevUsers.js 2>&1 | tee fixDevUsers.js.out


makeChatRoom:
	@echo makeChatRoom.js.out:1: output
	node --trace-uncaught makeChatRoom.js  2>&1 | tee makeChatRoom.js.out

friendTest:
	@echo friendTest.js.out:1: output
	node --trace-uncaught friendTest.js 2>&1 | tee friendTest.js.out
	
checkLogin:
	@echo checkLogin.js.out:1: output
	node --trace-uncaught checkLogin.js 2>&1 | tee checkLogin.js.out

testCellMessage:
	@echo testCellMessage.js.out:1: output
	node --trace-uncaught testCellMessage.js 2>&1 | tee testCellMessage.js.out

callGetUserData:
	@echo callGetUserData.js.out:1: output
	node --trace-uncaught callGetUserData.js 2>&1 | tee callGetUserData.js.out


allCall:
	@echo allCall.mjs.out:1: output
	node --trace-uncaught allCall.mjs 2>&1 | tee allCall.mjs.out

get:
	@echo callGetUserData.js.out:1:output
	node callGetUserData.js 2>&1 | tee out

test:
	yarn test

%: %.js
	./bin/record node $<

#    all:
#    	node buildNewTables.js

dump:
	node dumpData.js > dump.out 2>&1

undump:
	node undumpData.js	 | tee undump.out

#	npm run run 2>&1 | tee make.out
#

#all: testCellMessage


