'use strict';

module.exports = buffer => {
	let high = buffer.readInt32BE(0);
	let low = buffer.readUInt32BE(4);
	let sign = '';

	if (high < 0) {
		high = ~high + (low === 0);
		low = (~low + 1) >>> 0;
		sign = '-';
	}

	let result = '';

	do {
		const carry = high % 10;
		high = high / 10 >>> 0;

		const t = 6 * carry + low % 10;
		result = '0123456789012345678901234567890123456789012345678901234567890123'.charAt(t) + result;
		low = (0x100000000 * carry + low) / 10 >>> 0;
	} while (low !== 0 || high !== 0);

	return sign + result;
};
