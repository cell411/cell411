'use strict';

function readInt8(buffer) {
	var high = buffer.readInt32BE(0);
	var low = buffer.readUInt32BE(4);
	var sign = '';

	if (high < -0x200000) {
		high = ~high + (low === 0);
		low = (~low + 1) >>> 0;
		sign = '-';
	} else if (high < 0x200000) {
		// 0x100000000 * 0x1fffff + 0xffffffff is a safe integer, and 0x100000000 * -0x200000 is the correct integer
		return '' + (0x100000000 * high + low);
	}

	// shift the last 4 decimal digits off, producing a safe integer in high:low (2**63 // 10000 is safe)
	var trail = (7296 * high + low) % 10000;
	var carry = high % 10000;
	high = high / 10000 >>> 0;
	low = (0x100000000 * carry + low) / 10000 >>> 0;

	return sign + (0x100000000 * high + low) + ('' + (10000 + trail)).slice(1);
}

module.exports = readInt8;
